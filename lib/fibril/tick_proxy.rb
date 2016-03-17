class Fibril::TickProxy
  attr_accessor :target, :tick_before, :tick_after, :guard_names

  def initialize(target, *guard_names, tick_before: true, tick_after: false)
    self.target = target
    self.guard_names = guard_names
    self.tick_before, self.tick_after = tick_before, tick_after
  end

  ##
  # Execute target method within a new fibril
  ##
  def method_missing(name, *args, &block)
    context = target
    decorated = ->(*args){
      Fibril.current.tick if tick_before
      result = block[*args]
      Fibril.current.tick if tick_after
      result
    }
    fibril{
      context.send(name, *args, &decorated)
    }.tap do |guard|
      guard_names.each do |name|
        Fibril.guard.send("#{name}=", guard)
      end
    end

  end
end