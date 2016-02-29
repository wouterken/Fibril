require "fibril/version"
require 'ostruct'
require 'fc'

class Fibril < Fiber
  class << self
    attr_accessor :running, :stopped, :queue, :task_count, :guards, :current, :id_seq, :loop_thread
  end

  self.queue = []
  self.guards = Hash.new{|h,k| }
  self.id_seq = 0
  self.task_count = 0

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
    if Fibril.running
      super(&method(:execute))
      Fibril.enqueue self
    else
      Fibril.task_count = 0
      Fibril.stopped = false
      Fibril.running = true
      self.execute_fibril
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
    result = execute_fibril
    self.guards.each do |guard|
      guard.visit(result)
    end
    Fibril.task_count -= 1
    Fibril.log "Ending #{id}"
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
    return unless waiters = guards[guard.id]
    switches = waiters[:switches]
    switches[guard.id] = true
    if waiters.has_key?(:to_fulfill)
      Fibril.enqueue waiters[:to_fulfill]
      waiters[:result] = result
    else
      waiters[:block][] if waiters[:block] && switches.values.all?
    end
  end

  def await(*guards, &block)

    if guards.length == 1 && guards[0].kind_of?(Promise)
      return await_promise(guards[0])
    end

    if ! block_given?
      await_block = {
        switches: Hash[guards.map{|guard| [guard.id, false]}],
        to_fulfill: Fibril.current
      }
      guards.each do |guard|
        Fibril.guards[guard.id] = await_block
      end
      self.yield
      return await_block[:result]
    else
      await_block = {
        switches: Hash[guards.map{|guard| [guard.id, false]}],
        block: block
      }
      guards.each do |guard|
        Fibril.guards[guard.id] = await_block
      end
    end
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

    if !queue.empty?
      self.loop if !queue.empty? || Fibril.task_count > 0
    end
    self.running = false
  end

  def self.profile(test)
    starts = Time.now
    result = yield
    ends = Time.now
    puts "#{test} took #{ends - starts}"
    return result
  end

  def self.loop
    Fibril.log "Starting loop inside #{Fibril.current}"
    Fibril.loop_thread = Thread.current
    while ((@task_count > 0 || !@queue.empty?) && !@stopped)
      Fibril.current = nil
      while !@queue.empty?
        job = Fibril.queue.shift
        job.resume
      end
    end
  end

  def Guard(i, fibril)
    return Guard.new(i, fibril)
  end
end

Dir["#{File.dirname(__FILE__)}/fibril/*.rb"].each do |file|
  next if file =~ /loop/
  require file
end
