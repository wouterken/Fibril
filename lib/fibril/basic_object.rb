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

  ##
  # This method has two methods of use.
  # Either
  # A. call with block to create a new fibril
  # B. call without block to create a fibril proxy. Any methods invoked on a proxy are executed on the target from
  # within a new Fibril
  ##
  def fibril(&block)
    if block_given?
      Fibril(&block)
    else
      @fibril_proxy ||= ::Fibril::FibrilProxy.new(self)
    end
  end
end
