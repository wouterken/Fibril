require_relative "../lib/tendril/loop"

pending  = promise{ sleep 1; 3 }
pending2 = promise{ sleep 0.1; 4 }

weave{
  puts "First"
  puts async.await(pending)
  puts "First"
}

weave{
  puts "Second"
  result = async.await_all pending, pending2
  puts "Second"
  puts "Result is #{result}"
}

weave{
  puts "Third"
  puts async.await(pending2)
  puts "Third"
}
