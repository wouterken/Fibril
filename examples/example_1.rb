require_relative 'tendril'

require 'benchmark'


def get_5
  5.tap{ sleep 0.5 }
end

def get_res
  starts = Time.now
  res = get_5
  ends = Time.now
  puts "Get res took #{ends - starts}"
  res
end
Benchmark.bm do |bm|
  # bm.report{
  #   Tendril do
  #     i = 0
  #     await weave{ i = get_5 + 20 + i }.until{ i > 260 },
  #           weave{ i = get_5 + 100 + i }.loop(2) do
  #       puts "Final i is #{i}"
  #     end
  #   end
  # }

  # puts "Done"
  # sleep 2
  bm.report{

    Tendril do
      i = 0
      Tendril::async :sleep
      await(
            weave{ starts = Time.now; res = get_res;i = res + 20 + i; puts "Weave 1 took #{Time.now - starts}" }.until{ i > 260 },
            weave{ starts = Time.now; res = get_res;i = res + 100 + i; puts "Weave 2 took #{Time.now - starts}" }.loop(2)
          ) do
        puts "Final i is #{i}"
      end
    end
  }
end


# Tendril do
#   await weave{ puts 1; tick; puts 3 },
#         weave{ puts 2; tick; puts 4 } do
#       puts "Finished"
#   end
# end
#   }
# end



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