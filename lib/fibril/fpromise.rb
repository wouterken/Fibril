require_relative 'promise'

class Fibril::FPromise < Fibril::Promise
  def initialize(&blk)
    read, write = IO.pipe
    pid = fork do
      result = blk[]
      read.close
      Marshal.dump(result, write)
    end
    write.close
    result = nil
    self.promise_thread = Thread.new{
      result = read.read
      Process.wait(pid)
      Marshal.load(result)
    }
  end
end
