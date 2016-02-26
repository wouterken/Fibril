require_relative '../lib/fibril'
require "benchmark"

Benchmark.bm do |bm|
  bm.report{
    i = 0
    100.times do
      puts "A very long output statement : #{1}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{2}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{3}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{4}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{5}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{6}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{7}. Current thread: #{Thread.current}"
      puts "A very long output statement : #{8}. Current thread: #{Thread.current}"
    end
  }
  bm.report{
    i = 0

    100.times do
      Fibril do
        Fibril do
          puts "A very long output statement : #{1}. Current thread: #{Thread.current}"
          puts "A very long output statement : #{2}. Current thread: #{Thread.current}"
          tick
          puts "A very long output statement : #{3}. Current thread: #{Thread.current}"
          puts "A very long output statement : #{4}. Current thread: #{Thread.current}"
        end

        Fibril do
          puts "A very long output statement : #{5}. Current thread: #{Thread.current}"
          puts "A very long output statement : #{6}. Current thread: #{Thread.current}"
          tick
          puts "A very long output statement : #{7}. Current thread: #{Thread.current}"
          puts "A very long output statement : #{8}. Current thread: #{Thread.current}"
          Fibril.stop
        end
      end
    end
  }
  bm.report{
    i = 0
    100.times do
      Thread.new do
        [
          Thread.new do
            puts "A very long output statement : #{1}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{2}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{3}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{4}. Current thread: #{Thread.current}"
          end,
          Thread.new do
            puts "A very long output statement : #{5}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{6}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{7}. Current thread: #{Thread.current}"
            puts "A very long output statement : #{8}. Current thread: #{Thread.current}"
          end
        ].each(&:join)
      end.join
    end
  }
end

# Thread.new do
#   [
#     Thread.new do
#       puts "Big very very very very long message 1"
#       puts "Big very very very very long message 2"
#       puts "Big very very very very long message 5"
#       puts "Big very very very very long message 6"
#     end,
#     Thread.new do
#       puts "Big very very very very long message 3"
#       puts "Big very very very very long message 4"
#       puts "Big very very very very long message 7"
#       puts "Big very very very very long message 8"
#     end
#   ].each(&:join)
# end.join