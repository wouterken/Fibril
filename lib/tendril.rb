require "tendril/version"
require 'ostruct'


class Tendril < Fiber
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
    self.id = Tendril.id_seq += 1
    self.block  = blk
    self.guards = []
    define_singleton_method :execute_tendril, self.block
    super(&method(:execute))
    Tendril.queue << self
  end

  def reset(guard)
    copy = Tendril.new(&self.block)
    copy.guards << guard
    return copy
  end

  def execute
    Tendril.task_count += 1
    execute_tendril
    self.guards.each(&:visit)
    Tendril.task_count -= 1
    Tendril.log "Ending #{id}"
  end

  def tick
    Tendril.enqueue self
    self.yield
  end

  def self.enqueue(tendril)
    Tendril.log "Enqueing tendril #{tendril.id}"
    Tendril.queue << tendril
  end

  def yield
    Tendril.log "Yielding #{id}"
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
      Tendril.guards[guard.id] = await_block
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
    Tendril do
      Tendril.stopped = true
    end
  end

  def resume
    Tendril.current = self
    Tendril.log "Resuming #{id}"
    super
  end

  def self.start
    self.task_count = 0
    self.stopped = false
    self.running = true
    if queue.any?
      queue.shift.resume
      self.loop if queue.any? || Tendril.task_count > 0
    end
    self.running = false
  end

  def self.loop
    Tendril.log "Starting loop inside #{Tendril.current}"
    while ((Tendril.task_count > 0 || queue.any?) && !Tendril.stopped)
      Tendril.queue.shift.resume if Tendril.queue.any?
    end
  end

  def Guard(i, tendril)
    return Guard.new(i, tendril)
  end

  class AsyncProxy
    attr_accessor :target

    def initialize(target)
      self.target = target
    end

    def method_missing(name, *args, &block)
      waiting = Tendril.current
      Thread.new do
        target.send(name, *args, &block).tap{ Tendril.enqueue waiting }
      end.tap{
        Tendril.current.yield
      }.value
    end
  end


  class Guard
    class << self
      attr_accessor :guard_seq
    end

    attr_accessor :tendril, :id, :break_condition, :depleted

    self.guard_seq = 0

    def self.create(tendril, counter=1)
      self.guard_seq += 1
      guard = Tendril::Guard.new(self.guard_seq, counter, tendril)
      tendril.guards << guard
      return guard
    end

    def await
      Tendril.current.tick while !self.depleted
    end

    def initialize(id, counter, tendril)
      self.id = id
      self.tendril =  tendril
      self.break_condition = 1
    end

    def visit
      case self.break_condition
      when Proc
        if self.break_condition[]
          self.depleted = true
          Tendril.deplete_guard(self)
        else
          self.tendril    = self.tendril.reset(self)
        end
      else
        self.break_condition -= 1
        if self.break_condition.zero?
          self.depleted = true
          Tendril.deplete_guard(self)
        else
          self.tendril = self.tendril.reset(self)
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
    @async_proxy ||= ::Tendril::AsyncProxy.new(self)
  end
end


def Tendril(&block)
  tendril = Tendril.new(&block).tap do |t|
    Tendril.start unless Tendril.running
  end
  guard = Tendril::Guard.create(tendril)
end



Kernel.send :alias_method, :weave, :Tendril