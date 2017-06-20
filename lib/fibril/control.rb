##
# Expose thefuture and ffuture top level functions
##

##
# Create a new future
#

class ::BasicObject
  def future(&blk)
    return ::Fibril::Future.new(&blk)
  end

  ##
  # Create a new forked future
  ##
  def ffuture(&blk)
    return ::Fibril::FFuture.new(&blk)
  end
end