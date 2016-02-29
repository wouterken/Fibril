class Fibril::FibrilProxy
  attr_accessor :target

  def initialize(target)
    self.target = target
  end

  ##
  # Execute target method within a new fibril
  ##
  def method_missing(name, *args, &block)
    context = target
    fibril{
      context.send(name, *args, &block)
    }
  end
end