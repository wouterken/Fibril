##
# Expose thepromise and fpromise top level functions
##

##
# Create a new promise
##
class ::BasicObject
  def promise(&blk)
    return Fibril::Promise.new(&blk)
  end

  ##
  # Create a new forked promise
  ##
  def fpromise(&blk)
    return Fibril::FPromise.new(&blk)
  end
end