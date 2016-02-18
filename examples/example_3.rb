require_relative '../lib/fibril'
require "benchmark"

Benchmark.bm do |bm|
  bm.report{
    i = 0
    1_000.times do
      print "\rA very long output statement : #{1}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{2}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{3}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{4}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{5}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{6}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{7}. Current thread: #{Thread.current}"
      print "\rA very long output statement : #{8}. Current thread: #{Thread.current}"
    end
    puts
  }
  bm.report{
    i = 0

    1_000.times do
      Fibril do
        Fibril do
          print "\rA very long output statement : #{1}. Current thread: #{Thread.current}"
          print "\rA very long output statement : #{2}. Current thread: #{Thread.current}"
          tick
          print "\rA very long output statement : #{3}. Current thread: #{Thread.current}"
          print "\rA very long output statement : #{4}. Current thread: #{Thread.current}"
        end

        Fibril do
          print "\rA very long output statement : #{5}. Current thread: #{Thread.current}"
          print "\rA very long output statement : #{6}. Current thread: #{Thread.current}"
          tick
          print "\rA very long output statement : #{7}. Current thread: #{Thread.current}"
          print "\rA very long output statement : #{8}. Current thread: #{Thread.current}"
        end
      end
    end
    puts
  }
  bm.report{
    i = 0
    1_000.times do
      Thread.new do
        [
          Thread.new do
            print "\rA very long output statement : #{1}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{2}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{3}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{4}. Current thread: #{Thread.current}"
          end,
          Thread.new do
            print "\rA very long output statement : #{5}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{6}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{7}. Current thread: #{Thread.current}"
            print "\rA very long output statement : #{8}. Current thread: #{Thread.current}"
          end
        ].each(&:join)
      end.join
    end
    puts
  }
end

# Thread.new do
#   [
#     Thread.new do
#       print "\rBig very very very very long message 1"
#       print "\rBig very very very very long message 2"
#       print "\rBig very very very very long message 5"
#       print "\rBig very very very very long message 6"
#     end,
#     Thread.new do
#       print "\rBig very very very very long message 3"
#       print "\rBig very very very very long message 4"
#       print "\rBig very very very very long message 7"
#       print "\rBig very very very very long message 8"
#     end
#   ].each(&:join)
# end.join