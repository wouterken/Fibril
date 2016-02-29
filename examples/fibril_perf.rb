require_relative "../lib/fibril/loop"

$starts = Time.now

def finished
  # puts "Took #{Time.now - $starts}"
  tick if Fibril.current
end


a1 = fibril{
  finished

}.loop(5)

a2 = fibril{
  finished
}.loop(5)

await(a1, a2){
  puts "Total time was #{Time.now - $starts}"
  $starts = Time.now
  threads = 5.times.map{
    Thread.new{
      finished
    }
  }
  threads.concat(5.times.map{
    Thread.new{
      finished
    }
  })

  threads.each(&:join)
  puts "Total time was #{Time.now - $starts}"
}

