class Fibril::Promise
  attr_accessor :promise_thread
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