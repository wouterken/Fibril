class Fibril::NonBlockingIOWrapper
  attr_accessor :guard, :response_queue, :fibrils

  def initialize(*, &block)
    self.response_queue = []
    self.fibrils = []
    define_singleton_method(:loop, &block)
    promise{
      begin
        loop()
      rescue Exception => e
        puts "Exception! : #{e}"
        puts e.backtrace
      end
    }
  end

  def receive(*args)
    if args.any?
      ingest(*args)
    else
      method(:ingest)
    end
  end

  def ingest(*args)
    begin
      self.response_queue << args
      self.fibrils.shift.enqueue while self.fibrils.any?
    rescue Exception => e
      puts "Something happened! #{e}"
    end
  end

  def await
    Fibril.current.yield{|f| self.fibrils << f} until self.response_queue.any?
    self.response_queue.shift
  end
end