require 'fibril/loop'

pending  = future{ sleep 1; 3 }
pending2 = future{ sleep 0.1; 4 }

fibril{
  puts "Enter First"
  async.await(pending)
  puts "Leave First"
}

fibril{
  puts "Enter Second"
  result = async.await_all pending, pending2
  puts "Leave Second"
}

fibril{
  puts "Enter Third"
  async.await(pending2)
  puts "Leave Third"
}
