class Fibril::Promise
  attr_accessor :promise_thread

  ##
  # A promise. A very thin wrapper around a thread.
  # Can be used within `await` and `await_all` within a fibril
  ##

  def initialize(&blk)
    self.promise_thread = Thread.new(&blk)
  end

  def await
    self.promise_thread.join.value
  end

  def close
    self.promise_thread.kill
  end
end