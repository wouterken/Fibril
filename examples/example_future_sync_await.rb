require_relative "../lib/fibril/loop"

pending  = future{ sleep 1; 3 }
pending2 = future{ sleep 0.1; 4 }

fibril{
  puts "First"
  puts await(pending)
  puts "First"
}

fibril{
  puts "Second"
  result = await_all pending, pending2
  puts "Second"
  puts "Result is #{result}"
}

fibril{
  puts "Third"
  puts await(pending2)
  puts "Third"
}
