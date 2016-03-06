class ::BasicObject
  ##
  # Expose the async, fasync and fibril methods on all objects
  ##

  ##
  # An asynchronous proxy. Executes any methods invoked via proxy on target in a separate thread
  ##
  def async
    @async_proxy ||= ::Fibril::AsyncProxy.new(self)
  end

  ##
  # An asynchronous proxy. Executes any methods invoked via proxy on target in a separate fork
  ##
  def fasync
    @fasync_proxy ||= ::Fibril::FAsyncProxy.new(self)
  end
end
