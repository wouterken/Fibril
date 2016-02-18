require_relative "../lib/tendril/loop"

weave{
  puts 1
  tick
  puts 2
}

weave{
  puts 3
  tick
  puts 4
}

# Kernel.send :alias_method, :old_puts, :puts
# Tendril::async :puts

# puts 1
# puts 2
# puts 3

# puts 4
# puts 5
# puts 6

# sleep

# old_puts "Done!"