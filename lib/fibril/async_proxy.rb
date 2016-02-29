class Fibril::AsyncProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  ##
  # Execute target method on proxied target. Enqueue the current fibril
  # to be resumed as soon as async task is finished
  ##
  def method_missing(name, *_args, &_block)
    define_singleton_method(name) do |*args, &block|
      waiting = Fibril.current
      Thread.new do
        target.send(name, *args, &block).tap{ Fibril.enqueue waiting }
      end.tap do
        Fibril.current.yield
      end.value
    end
    send(name, *_args, &_block)
  end
end