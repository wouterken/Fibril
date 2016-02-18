require "fibril/version"
require 'ostruct'


class Fibril < Fiber
  class << self
    attr_accessor :running, :stopped, :queue, :task_count, :guards, :current, :id_seq
  end

  self.queue = []
  self.guards = Hash.new{|h,k| }
  self.id_seq = 0

  attr_accessor :fiber, :guards, :block, :id

  def self.log(msg)
    # puts msg
  end

  def variables
    @@variables ||= OpenStruct.new
  end

  def initialize(&blk)
    self.id = Fibril.id_seq += 1
    self.block  = blk
    self.guards = []
    define_singleton_method :execute_fibril, self.block
    super(&method(:execute))
    Fibril.queue << self
  end

  def reset(guard)
    copy = Fibril.new(&self.block)
    copy.guards << guard
    return copy
  end

  def execute
    Fibril.task_count += 1
    execute_fibril
    self.guards.each(&:visit)
    Fibril.task_count -= 1
    Fibril.log "Ending #{id}"
  end

  def tick
    Fibril.enqueue self
    self.yield
  end

  def self.enqueue(fibril)
    Fibril.log "Enqueing fibril #{fibril.id}"
    Fibril.queue << fibril
  end

  def yield
    Fibril.log "Yielding #{id}"
    Fiber.yield
  end

  def current
    self
  end

  def self.deplete_guard(guard)
    return unless waiters = guards[guard.id]
    switches = waiters[:switches]
    switches[guard.id] = true
    waiters[:block][] if switches.values.all?
  end

  def await(*guards, &block)

    if guards.length == 1 && guards[0].kind_of?(Promise)
      return await_promise(guards[0])
    end

    await_block = {
      switches: Hash[guards.map{|guard| [guard.id, false]}],
      block: block
    }
    guards.each do |guard|
      Fibril.guards[guard.id] = await_block
    end
  end

  def promise(&blk)
    return Promise.new(&blk)
  end

  def await_promise(promise)
    promise.await
  end

  def await_all(*promises)
    promises.map(&:await)
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
    self.task_count = 0
    self.stopped = false
    self.running = true
    if queue.any?
      queue.shift.resume
      self.loop if queue.any? || Fibril.task_count > 0
    end
    self.running = false
  end

  def self.loop
    Fibril.log "Starting loop inside #{Fibril.current}"
    while ((Fibril.task_count > 0 || queue.any?) && !Fibril.stopped)
      Fibril.queue.shift.resume if Fibril.queue.any?
    end
  end

  def Guard(i, fibril)
    return Guard.new(i, fibril)
  end

  class AsyncProxy
    attr_accessor :target

    def initialize(target)
      self.target = target
    end

    def method_missing(name, *args, &block)
      waiting = Fibril.current
      Thread.new do
        target.send(name, *args, &block).tap{ Fibril.enqueue waiting }
      end.tap{
        Fibril.current.yield
      }.value
    end
  end


  class Guard
    class << self
      attr_accessor :guard_seq
    end

    attr_accessor :fibril, :id, :break_condition, :depleted

    self.guard_seq = 0

    def self.create(fibril, counter=1)
      self.guard_seq += 1
      guard = Fibril::Guard.new(self.guard_seq, counter, fibril)
      fibril.guards << guard
      return guard
    end

    def await
      Fibril.current.tick while !self.depleted
    end

    def initialize(id, counter, fibril)
      self.id = id
      self.fibril =  fibril
      self.break_condition = 1
    end

    def visit
      case self.break_condition
      when Proc
        if self.break_condition[]
          self.depleted = true
          Fibril.deplete_guard(self)
        else
          self.fibril    = self.fibril.reset(self)
        end
      else
        self.break_condition -= 1
        if self.break_condition.zero?
          self.depleted = true
          Fibril.deplete_guard(self)
        else
          self.fibril = self.fibril.reset(self)
        end
      end
    end

    def loop(break_condition=-1, &blck)
      self.break_condition = block_given? ? blck : break_condition
      self
    end

    def while(&blk)
      loop{ !blk[] }
    end

    def until(&blk)
      loop{ blk[] }
    end
  end

  class Promise
    attr_accessor :promise_thread
    def initialize(&blk)
      self.promise_thread = Thread.new(&blk)
    end

    def await
      self.promise_thread.join.value
    end
  end

end

class ::BasicObject
  def async
    @async_proxy ||= ::Fibril::AsyncProxy.new(self)
  end
end


def Fibril(&block)
  fibril = Fibril.new(&block).tap do |t|
    Fibril.start unless Fibril.running
  end
  guard = Fibril::Guard.create(fibril)
end



Kernel.send :alias_method, :fibril, :Fibril