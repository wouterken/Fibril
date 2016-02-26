require_relative 'non_blocking_io_wrapper'

class Fibril::ForkedNonBlockingIOWrapper < Fibril::NonBlockingIOWrapper
  attr_accessor :read, :write
  require 'uri'

  def initialize(*, &block)
    read, write = IO.pipe
    self.read, self.write = read, write
    self.response_queue = []
    self.fibrils = []
    define_singleton_method(:loop, &block)
  end

  def start
    freceive = method(:freceive)
    block = method(:loop)
    read, write = self.read, self.write
    fibril{
      fork do
        read.close
        block[]
      end

      write.close
      begin
        Fibril.current.tick
        while message = read.gets
          freceive[*Marshal.load(URI.unescape(message))]
          Fibril.current.tick
        end
      rescue Exception => e
        puts "Exception! : #{e}"
        puts e.backtrace
      end
    }
  end

  def receive(*args)
    self.write.puts URI.escape(Marshal.dump(args)) rescue nil
  end

  def freceive(*args)
    if args.any?
      ingest(*args)
    else
      method(:ingest)
    end
  end
end