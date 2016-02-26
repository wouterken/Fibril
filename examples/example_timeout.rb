require_relative "../lib/fibril/loop"


def puts_hi
  puts "hi"
end


fibril.puts_hi.loop(200, 0.001)