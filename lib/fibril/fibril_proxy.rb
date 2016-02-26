class Fibril::FibrilProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  def method_missing(name, *args, &block)
    context = target
    fibril{
      context.send(name, *args, &block)
    }
  end
end