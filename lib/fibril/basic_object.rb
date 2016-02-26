class ::BasicObject
  def async
    @async_proxy ||= ::Fibril::AsyncProxy.new(self)
  end

  def fasync
    @fasync_proxy ||= ::Fibril::FAsyncProxy.new(self)
  end

  def fibril(&block)
    if block_given?
      Fibril(&block)
    else
      @fibril_proxy ||= ::Fibril::FibrilProxy.new(self)
    end
  end
end
