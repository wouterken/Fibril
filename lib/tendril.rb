require "tendril/version"

class Tendril < Fiber
  class << self
    attr_accessor :running, :stopped, :queue, :task_count, :guards, :current
  end

  self.queue = []
  self.guards = Hash.new{|h,k| }

  attr_accessor :fiber, :guards, :block

  def initialize(&blk)
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
  end

  def tick
    Tendril.queue << self
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
    await_block = {
      switches: Hash[guards.map{|guard| [guard.id, false]}],
      block: block
    }
    guards.each do |guard|
      Tendril.guards[guard.id] = await_block
    end
  end

  def self.stop
    Tendril do
      Tendril.stopped = true
    end
  end

  def resume
    Tendril.current = self
    super
  end

  def self.start
    self.task_count = 0
    self.stopped = false
    self.running = true
    if queue.any?
      queue.shift.resume
      self.loop if queue.any?
    end
    self.running = false
  end

  def self.loop
    while ((Tendril.task_count > 1 || queue.any?) && !Tendril.stopped)
      Tendril.queue.shift.resume if Tendril.queue.any?
    end
  end

  def Guard(i, tendril)
    return Guard.new(i, tendril)
  end

  def perform_async
    self.tick
    Thread.new do
      yield.tap{ Tendril.queue << self }
    end.tap{
      Fiber.yield
    }.value
  end

  def self.async(method_name)
    aliased_method = "_#{method_name}"
    alias_method aliased_method, method_name
    define_method(method_name) do |*args|
      self.perform_async do
        send(aliased_method, *args)
      end
    end
  end


  class AsyncProxy
    attr_accessor :target

    def initialize(target)
      self.target = target
    end

    def method_missing(name, *args, &block)
      ::Tendril.perform_async do
        target.send(name, *args, &block)
      end
    end
  end
end

  class ::BasicObject
    def async
      @async_proxy ||= ::Tendril::AsyncProxy.new(self)
    end
  end


  class Tendril::Guard
    class << self
      attr_accessor :guard_seq
    end

    attr_accessor :tendril, :id, :break_condition

    self.guard_seq = 0

    def self.create(tendril, counter=1)
      self.guard_seq += 1
      guard = Tendril::Guard.new(self.guard_seq, counter, tendril)
      tendril.guards << guard
      return guard
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
          Tendril.deplete_guard(self)
        else
          self.tendril    = self.tendril.reset(self)
        end
      else
        self.break_condition -= 1
        if self.break_condition.zero?
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


def Tendril(&block)
  tendril = Tendril.new(&block).tap do |t|
    Tendril.start unless Tendril.running
  end
  guard = Tendril::Guard.create(tendril)
end



Kernel.send :alias_method, :weave, :Tendril