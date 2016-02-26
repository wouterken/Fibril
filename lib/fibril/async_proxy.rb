class Fibril::AsyncProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  def method_missing(name, *_args, &_block)
    define_singleton_method(name){|*args, &block|
      waiting = Fibril.current
      Thread.new do
        target.send(name, *args, &block).tap{ Fibril.enqueue waiting }
      end.tap{
        Fibril.current.yield
      }.value
    }
    send(name, *_args, &_block)
  end
end