require_relative "../lib/tendril/loop"

weave{
[1,2,3].async.each do |i|
  puts i
end
}

weave{
[4,5,6].async.each do |i|
  puts i
end
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