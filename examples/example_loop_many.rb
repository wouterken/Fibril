puts 'before loop'

require_relative "../lib/fibril/loop"


array = [0] * 2_0_000
array2 = [0] * 2_0_000
puts "Finished creating buffer"

Fibril.profile(:sync){
  10_000.times{|i|
    array[i] = i
    array[i + 10_000] = 10_000 + i
  }
}


Fibril.profile(:fibril){
  10_000.times{ |i|
    fibril{
      array2[i] = i
      # tick
      array2[10_000 + i] = 10_000 + i
    }
  }
}


fibril{
  async.sleep 0.5
  puts "Total itime #{Fibril.total_init_time}"
}