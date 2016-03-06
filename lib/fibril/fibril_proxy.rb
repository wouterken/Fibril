class Fibril::FibrilProxy
  attr_accessor :target, :guard_names

  ENUM_METHODS = %w(map each each_with_index with_index with_object detect select each_slice each_cons each_entry reverse_each)

  def initialize(target, *guard_names)
    self.target = target
    self.guard_names = guard_names
  end

  ##
  # Execute target method within a new fibril
  ##
  def method_missing(name, *args, &block)

    context = target

    return context.send(name).fibril(*self.guard_names) do |*elms, &blk|
      block[*elms, &blk]
    end if ENUM_METHODS.include?(name.to_s)


    fibril{
      context.send(name, *args, &block)
    }.tap do |guard|
      guard_names.each do |guard_name|
        Fibril.guard.send("#{guard_name}=", guard)
      end
    end
  end
end