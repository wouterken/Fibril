class Fibril::Guard
  class << self
    attr_accessor :guard_seq
  end

  attr_accessor :fibril, :id, :break_condition, :depleted, :timeout_period, :result, :depleted_at

  class NoResult;end

  self.guard_seq = 0

  ##
  # Create a new guard for a given fibril and add a reference to it to this same fibril.
  ##
  def self.create(fibril, counter=1)
    self.guard_seq += 1
    guard = Fibril::Guard.new(self.guard_seq, counter, fibril)
    fibril.guards << guard
    return guard
  end

  def result?
    self.result != NoResult
  end

  def depleted?
    depleted
  end
  ##
  # Continue to process fibrils until this guard is depleted.
  ##
  def await
    Fibril.current.tick while !self.depleted
  end

  ##
  # Schedule this guard to deplete the next time it is visited
  ##
  def cancel
    self.break_condition = 1
  end

  ##
  # Create a new guard object. A guard can have a break condition which is either
  # A. A counter, guard will deplete when it has been visited this many times
  # B. A break condition, guard will deplete when this proc/lambda returns true
  ##
  def initialize(id, counter, fibril)
    self.id = id
    self.fibril =  fibril
    self.break_condition = counter
    self.result = NoResult
  end

  ##
  # Visit this guard. This is called everytime the fibril associated with this guard
  # completes. If the guard does not deplete the fibril resets and runs again
  ##
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

  ##
  # Deplete the guard. The guard has served its purpose
  ##
  def deplete(result)
    self.result = result
    self.depleted = true
    self.depleted_at = Time.now
    Fibril.deplete_guard(self, result)
  end

  ##
  # Loop the fibril associated with a guard either a set number of times
  # or until a block evaluates to true
  ##
  def loop(break_condition=-1, timeout=0, &blck)
    self.break_condition = block_given? ? blck : break_condition
    self.timeout_period = timeout
    self
  end

  ##
  # The inverse of loop. Loop until a block evalutes to true
  ##
  def while(&blk)
    loop{ !blk[] }
  end

  ##
  # Equivalent of loop
  ##
  def until(*guards, &blk)
    if block_given?
      loop{ blk[] }
    else
      loop{
        guards.map{|guard| guard.kind_of?(Symbol) ? Fibril.guard.send(guard) : guard}.all?(&:depleted?)
      }
    end
  end
end