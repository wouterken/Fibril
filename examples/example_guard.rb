require_relative "../lib/tendril/loop"

weave{
  variables.guard.await
  puts "First finished"
}

variables.guard = weave{
  sleep 0.2
  puts "Second finished"
}.until{ true }

await(variables.guard){
  puts "Guard depleted"
}