require_relative "../lib/fibril/loop"

fibril{
  variables.guard.await
  puts "First finished"
}

variables.guard = fibril{
  sleep 0.2
  puts "Second finished"
}.until{ true }

await(variables.guard){
  puts "Guard depleted"
}