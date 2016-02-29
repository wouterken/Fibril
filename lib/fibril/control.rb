##
# Expose the Fibril, promise and fpromise top level functions
##

##
# Create a new fibril
##
def Fibril(&block)
  fibril = Fibril.new(&block)
  Fibril::Guard.create(fibril)
end

##
# Create a new promise
##
def promise(&blk)
  return Fibril::Promise.new(&blk)
end

##
# Create a new forked promise
##
def fpromise(&blk)
  return Fibril::FPromise.new(&blk)
end
