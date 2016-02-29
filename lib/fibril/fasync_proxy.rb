class FAsyncProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  def method_missing(name, *_args, &_block)
    define_singleton_method(name){|*args, &block|
      read, write = IO.pipe
      waiting = Fibril.current
      pid = fork do
        result = target.send(name, *args, &block)
        read.close
        Marshal.dump(result, write)
      end
      write.close
      result = nil
      Thread.new{
        result = read.read
        Process.wait(pid)
        Fibril.enqueue waiting
      }
      Fibril.current.yield
      Marshal.load(result)
    }
    send(name, *_args, &_block)
  end
end