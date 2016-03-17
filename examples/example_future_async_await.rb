require_relative "../lib/fibril/loop"

pending  = future{ sleep 1; 3 }
pending2 = future{ sleep 0.1; 4 }

fibril{
  puts "First"
  puts async.await(pending)
  puts "First"
}

fibril{
  puts "Second"
  result = async.await_all pending, pending2
  puts "Second"
  puts "Result is #{result}"
}

fibril{
  puts "Third"
  puts async.await(pending2)
  puts "Third"
}
