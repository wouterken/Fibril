require 'fibril/guard'
require 'fibril/future'
require 'fibril/fibril_proxy'
require 'fibril/tick_proxy'
require 'ostruct'

class Fibril < Fiber
  class << self
    attr_accessor :running, :stopped, :queue, :task_count, :guards, :current, :id_seq, :loop_thread
  end

  self.queue = []
  self.guards = Hash.new{|h,k| h[k] = [] }
  self.id_seq = 0
  self.task_count = 0

  attr_accessor :fiber, :guards, :block, :id

  def self.log(msg)
    # puts msg
  end

  def guard
    Fibril.guard
  end

  def self.guard
    @@guard ||= OpenStruct.new
  end

  def variables
    Fibril.variables
  end

  def self.variables
    @@variables ||= OpenStruct.new
  end

  def initialize(&blk)
    self.id = Fibril.id_seq += 1
    self.block  = blk
    self.guards = []
    define_singleton_method :execute_fibril, self.block
    if Fibril.running
      super(&method(:execute))
      Fibril.enqueue self
    else
      Fibril.task_count = 0
      Fibril.stopped = false
      Fibril.running = true
      super(&method(:execute))
      Fibril.enqueue self
      Fibril.start
    end
  end

  def reset(guard)
    copy = Fibril.new(&self.block)
    copy.guards << guard
    return copy
  end

  def execute
    Fibril.task_count += 1
    exception = nil
    result = begin
      execute_fibril
    rescue Exception => e
      exception = e
    end
    self.guards.each do |guard|
      guard.visit(result)
    end
    Fibril.task_count -= 1
    Fibril.log "Ending #{id}"
    raise exception if exception
  end

  def tick
    if Thread.current != Fibril.loop_thread
      Fibril.log "Current thread is #{Thread.current.object_id}"
      Fibril.log "Fibril thread is #{Fibril.loop_thread.object_id}"
      Fibril.log "WARN: Cannot tick inside async code outside of main loop thread. This will be a noop"
    elsif !Fibril.queue.empty?
      Fibril.enqueue self
      self.yield
    end
  end

  def enqueue
    Fibril.enqueue(self)
  end

  def self.enqueue(fibril)
    Fibril.log "Enqueing fibril #{fibril.id}"
    Fibril.queue << fibril
  end

  def yield
    Fibril.log "Yielding #{id}"
    yield(self) if block_given?
    Fiber.yield
  end

  def current
    self
  end

  def self.deplete_guard(guard, result)
    return unless waiter_list = guards[guard.id]
    waiter_list.each do |waiters|
      switches = waiters[:switches]
      switches[guard.id] = true
      if waiters.has_key?(:to_fulfill)
        Fibril.enqueue waiters[:to_fulfill] if switches.values.all?
        waiters[:result] ||= []
        waiters[:result] << result
      else
        waiters[:result] ||= []
        waiters[:result] << result
        waiters[:block][*sort_results(waiters[:result], waiters[:guards])] if waiters[:block] && switches.values.all?
      end
    end
  end

  def await_fibril(guards)
    singular = guards.one?
    return singular ? guards[0].result : guards.map(&:result) if guards.all?(&:result?)
    await_block = {
      switches: Hash[guards.map{|guard| [guard.id, false]}],
      to_fulfill: Fibril.current
    }
    guards.each do |guard|
      Fibril.guards[guard.id] << await_block
    end
    self.yield
    return singular ? await_block[:result][0] : Fibril.sort_results(await_block[:result], guards)
  end

  def self.sort_results(results, guards)
    by_complete_order = guards.sort_by(&:depleted_at)
    results.zip(by_complete_order).sort do |(_, guard_a), (_, guard_b)|
      guards.index(guard_a) <=> guards.index(guard_b)
    end.map(&:first)
  end

  def await(*guards, &block)
    guards.map!{|guard| guard.kind_of?(Symbol) ? Fibril.guard.send(guard) : guard}
    raise "Invalid guard given #{guards}" unless guards.all?{|g| g.kind_of?(Guard) || g.kind_of?(Future)}
    if block_given?
      return block[*guards.map(&:result)] if guards.all?(&:result?)
      await_block = {
        switches: Hash[guards.map{|guard| [guard.id, false]}],
        block: block,
        guards: guards
      }
      guards.each do |guard|
        Fibril.guards[guard.id] << await_block
      end
    else
      guard = guards.first
      guard.kind_of?(Future) ? await_future(guard) : await_fibril(guards)
    end
  end

  def await_future(future)
    tick while future.alive?
    future.await
  end

  def await_all(*futures)
    futures.map(&:await)
  end

  def self.stop
    Fibril do
      Fibril.stopped = true
    end
  end

  def resume
    Fibril.current = self
    Fibril.log "Resuming #{id}"
    super
  end

  def self.start
    self.start_loop if !queue.empty?
    self.running = false
  end

  def self.profile(test)
    starts = Time.now
    result = yield
    ends   = Time.now
    Fibril.log "#{test} took #{ends - starts}"
    return result
  end

  def self.start_loop
    Fibril.log "Starting loop inside #{Fibril.current}"
    Fibril.loop_thread = Thread.current
    while pending_tasks?
      Fibril.current = nil
      Fibril.queue.shift.resume while !queue.empty?
    end
  end

  def self.pending_tasks?
    ((@task_count > 0 || !@queue.empty?) && !@stopped)
  end

  def Guard(i, fibril)
    return Guard.new(i, fibril)
  end
end


##
# Create a new fibril
##
def Fibril(*guard_names, &block)
  fibril = Fibril.new(&block)
  return fibril unless Fibril.running
  Fibril::Guard.create(fibril).tap do |guard|
    guard_names.each do |name|
      Fibril.guard.send("#{name}=", guard)
    end
  end
end

class Enumerator
  def fibril(*guard_names, &block)
    context = self
    Kernel.fibril(*guard_names){
      e = Enumerator.new do |enum|
        context.each do |*elm|
          result = enum.yield(*elm)
          tick
          result
        end
      end
      e.each(&block)
    }
  end

  def n_fibrils(*guard_names, n, &block)
    context = self

    guards = n.times.map do |i|
      Kernel.fibril{
        e = Enumerator.new do |enum|
          context.each.with_index do |elm, index|
            next unless ((index - i) % n).zero?
            result = enum.yield(*elm)
            tick
            result
          end
        end
        e.each(&block)
      }
    end
    Kernel.fibril(*guard_names){
      all_results = await(*guards)
      length = all_results.max{|x| x.length}.length
      length.times.map do |i|
        all_results.find{|list|
          list[i] != nil
        }[i]
      end
    }
  end
end

class ::BasicObject
  ##
  # This method has two methods of use.
  # Either
  # A. call with block to create a new fibril
  # B. call without block to create a fibril proxy. Any methods invoked on a proxy are executed on the target from
  # within a new Fibril
  ##
  def fibril(*guard_names, &block)
    if block_given?
      Fibril(*guard_names, &block)
    else
      ::Fibril::FibrilProxy.new(self, *guard_names)
    end
  end

  def tick(*guard_names, **args)
    ::Fibril::TickProxy.new(self, *guard_names, **args)
  end

  def await(*args, &block)
    Fibril.current.await(*args, &block)
  end
end
