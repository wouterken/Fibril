require_relative "../lib/fibril/loop"

[*0...10].tick(:result_one).map do |i|
  print "#{i} "
  i * 3
end

[*10...20].tick(:result_two).map do |i|
  print "#{i} "
  async.sleep 0.001
  i * 11
end

 fibril(:result_three){
  async.sleep 0.5
  puts "Three finished"
}

await(guard.result_one, guard.result_two){
  puts "f2"
  puts (await guard.result_one).zip((await guard.result_two)).inject(:+)
  await(guard.result_three){
    puts "Continued!"
  }
}


await(guard.result_one){
  puts "f1"
  puts "\n#{await guard.result_one}"
  puts "\n#{await guard.result_two}"
}



fibril{
  res = await(guard.res_one, guard.res_two)
  puts "Res is #{res}"
}

fibril(:res_one){
  async.sleep 0.5
  "hello"
}

fibril(:res_two){
  async.sleep 0.1
  "world"
}
