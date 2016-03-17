require_relative "../lib/fibril/loop"

def heartbeat
  puts "•"
end

fibril.puts('ping').loop(20, 0.5)
fibril{ puts "pong" }.loop(20, 0.5)
fibril.heartbeat.loop(2, 2)