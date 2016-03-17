require_relative "../lib/fibril/loop"

fibril{
  puts 1
  tick
  puts 3
}

fibril{
  puts 2
  tick
  puts 4
}