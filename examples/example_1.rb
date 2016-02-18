require_relative '../lib/fibril'

require 'benchmark'


def get_5
  5.tap{ async.sleep 0.5 }
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
  #   Fibril do
  #     i = 0
  #     await fibril{ i = get_5 + 20 + i }.until{ i > 260 },
  #           fibril{ i = get_5 + 100 + i }.loop(2) do
  #       puts "Final i is #{i}"
  #     end
  #   end
  # }

  # puts "Done"
  # sleep 2
  bm.report{

    Fibril do
      i = 0
      await(
            fibril{ starts = Time.now; res = get_res;i = res + 20 + i; puts "Weave 1 took #{Time.now - starts}" }.until{ i > 260 },
            fibril{ starts = Time.now; res = get_res;i = res + 100 + i; puts "Weave 2 took #{Time.now - starts}" }.loop(2)
          ) do
        puts "Final i is #{i}"
      end
    end
  }
end


# Fibril do
#   await fibril{ puts 1; tick; puts 3 },
#         fibril{ puts 2; tick; puts 4 } do
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