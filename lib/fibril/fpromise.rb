require_relative 'promise'

class Fibril::FPromise < Fibril::Promise

  ##
  # A Forked promise. Fulfils the same promise api as Fibril::Promise
  # but runs the block inside a new fork instead of a new thread..
  ##
  def initialize(&blk)
    read, write = IO.pipe
    pid = fork do
      result = blk[]
      read.close
      Marshal.dump(result, write)
    end
    write.close
    result = nil
    self.promise_thread = Thread.new do
      result = read.read
      Process.wait(pid)
      Marshal.load(result)
    end
  end
end
