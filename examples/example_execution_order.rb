require_relative "../lib/fibril/loop"

fibril{
  puts "I'm executed second"
  fibril{
    puts "I'm executed last"
  }
}

fibril{
  puts "I'm executed third"
}

puts "I'm executed first"