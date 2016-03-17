require_relative "../lib/fibril/loop"

[*0...10].tick(:result_one).map do |i|
  print "Item-1-#{i}, "
  i * 3
end

[*10...20].tick(:result_two).map do |i|
  print "Item-2-#{i}, "
  i * 11
end

 fibril(:result_three){
  async.sleep 0.5
  puts "Three finished"
}

await(guard.result_one, guard.result_two){
  puts "\nSum guard one & two:"
  puts (await guard.result_one).zip((await guard.result_two)).inject(:+).to_s
  await(guard.result_three){
    puts "Continued!"
  }
}

await(guard.result_one){
  puts "\nGuard one results:"
  puts "#{await guard.result_one}"
  puts "Guard two results: #{await guard.result_two}"
}


fibril{
  res = await(guard.result_four, guard.result_five)
  puts "Res is #{res}"
}

fibril(:result_four){
  async.sleep 0.5
  "hello"
}

fibril(:result_five){
  async.sleep 0.1
  "world"
}
