require_relative 'future'

class Fibril::FFuture < Fibril::Future

  ##
  # A Forked future. Fulfils the same future api as Fibril::Future
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
    self.future_thread = Thread.new do
      result = read.read
      Process.wait(pid)
      Marshal.load(result)
    end
  end
end
