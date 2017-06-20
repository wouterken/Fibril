require 'fibril/loop'

fibril(:g1){
  sleep 1
  4
}

fibril(:g2){
  5
}

fibril{
  puts "Sum is " + (await(:g1) + await(:g2)).to_s
  puts "Sum is " + (await(guard.g1) + await(guard.g2)).to_s
}

await(:g2){|res|
  puts "g2 available immediately: #{res}"
}