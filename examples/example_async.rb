require_relative "../lib/fibril/loop"

fibril{
[1,2,3].async.each do |i|
  puts i
end
}

fibril{
[4,5,6].async.each do |i|
  puts i
end
}
# Kernel.send :alias_method, :old_puts, :puts
# Fibril::async :puts

# puts 1
# puts 2
# puts 3

# puts 4
# puts 5
# puts 6

# sleep

# old_puts "Done!"