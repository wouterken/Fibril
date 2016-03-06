class Fibril::NonBlockingIOWrapper
  ##
  # A Non block IO wrapper allows you to execute a blocking IO loop inside a separate thread
  # and receive all inputs inside one or more Fibrils.
  #
  # This allows you to have multiple block IO loops operating in parallel whilst still processing all
  # resulting messages in the main thread.
  ##
  attr_accessor :guard, :response_queue, :fibrils

  def initialize(*, &block)
    self.response_queue = []
    self.fibrils = []
    define_singleton_method(:loop, &block)
    promise{
      begin
        loop()
      rescue Exception => e
        puts "Exception occurred in thead #{Thread.current} : #{e.message}"
        puts e.backtrace
      end
    }
  end

  ##
  # Receive a message from the async IO loop if a message is sent, otherwise return a reference to the ingest method
  ##
  def receive(*args)
    if args.any?
      ingest(*args)
    else
      method(:ingest)
    end
  end

  ##
  # Add the ingested message to the response queue and schedule all fibrils
  # waiting on events to receive messages
  ##
  def ingest(*args)
    begin
      self.response_queue << args
      self.fibrils.shift.enqueue while self.fibrils.any?
    rescue Exception => e
      puts "Exception occurred when ingesting from #{self} : #{e.message}"
      puts e.backtrace
    end
  end

  def await
    ##
    # Set all fibrils into waiting state until there is something in the response queue
    ##
    Fibril.current.yield{|f| self.fibrils << f} until self.response_queue.any?
    ##
    # Return values from the response queue
    ##
    self.response_queue.shift
  end
end