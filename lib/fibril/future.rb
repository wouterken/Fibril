class Fibril::Future
  attr_accessor :future_thread

  ##
  # A future. A very thin wrapper around a thread.
  # Can be used within `await` and `await_all` within a fibril
  ##

  def initialize(&blk)
    self.future_thread = Thread.new(&blk)
  end

  def await
    self.future_thread.join.value
  end

  def alive?
    self.future_thead.alive?
  end

  def close
    self.future_thread.kill
  end
end