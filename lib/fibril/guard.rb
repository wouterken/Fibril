class Fibril::Guard
  class << self
    attr_accessor :guard_seq
  end

  attr_accessor :fibril, :id, :break_condition, :depleted, :timeout_period

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

  def cancel
    self.break_condition = 1
  end

  def initialize(id, counter, fibril)
    self.id = id
    self.fibril =  fibril
    self.break_condition = counter
  end

  def visit(result=nil)
    case self.break_condition
    when Proc
      if self.break_condition[]
        self.deplete(result)
      else
        self.fibril    = self.fibril.reset(self)
      end
    else
      self.break_condition -= 1
      if self.break_condition.zero?
        self.deplete(result)
      else
        unless timeout_period.zero?
          if timeout_period > 0.1
            async.sleep(timeout_period)
          else
            sleep(timeout_period)
          end
        end
        self.fibril = self.fibril.reset(self)
      end
    end
  end

  def deplete(result)
    self.depleted = true
    Fibril.deplete_guard(self, result)
  end

  def loop(break_condition=-1, timeout=0, &blck)
    self.break_condition = block_given? ? blck : break_condition
    self.timeout_period = timeout
    self
  end

  def while(&blk)
    loop{ !blk[] }
  end

  def until(&blk)
    loop{ blk[] }
  end
end