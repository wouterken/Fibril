require_relative "../lib/fibril/loop"

[1,2,3,4,5,6,7,8].each.with_index.n_fibrils(:n_fibrils, 4) do |elm, i|
  puts "Start: #{elm}"
  async.sleep ((4 - (i % 4)) / 2)./(100.0)
  puts "Finish: #{elm}"
end


await(:n_fibrils){
  [1,2,3,4].map.fibril(:g1) do |i|
    i ** 3
  end

  [5,6,7,8].select{|x| x % 2 == 0}.map.fibril(:g2) do |i|
     i / 12.0
  end


  fibril{
    puts "#{await(:g1, :g2)}"
  }
}