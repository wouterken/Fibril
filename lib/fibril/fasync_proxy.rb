class FAsyncProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  ##
  # Execute target method within a new fork. Enqueue the current fibril
  # to be resumed as soon as async task is finished.
  # The result of the forked process is passed to the parent by Marshaling.
  ##
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