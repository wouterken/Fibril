require_relative "../lib/tendril/loop"

weave{
  puts 1
  tick
  puts 3
}

weave{
  puts 2
  tick
  puts 4
}