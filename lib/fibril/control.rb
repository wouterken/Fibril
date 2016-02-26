def Fibril(&block)
  fibril = Fibril.new(&block).tap do |t|
    Fibril.start unless Fibril.running
  end
  Fibril::Guard.create(fibril)
end


def promise(&blk)
  return Fibril::Promise.new(&blk)
end

def fpromise(&blk)
  return Fibril::FPromise.new(&blk)
end
