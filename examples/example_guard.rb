require 'fibril/loop'

fibril{
  puts "Waiting on below fibril"
  await(guard.g1)
  puts "First finished"
}

guard.g1 = fibril{
  sleep 0.2
  puts "Middle finished"
}

puts "Waiting on above"
await(guard.g1){
  puts "Third finished"
}