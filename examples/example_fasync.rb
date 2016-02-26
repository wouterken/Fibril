require_relative "../lib/fibril/loop"

def count_bytes(file)
  byte_counter = Hash.new(0)
  File.foreach(file) do |line|
    line.each_byte do |b|
      byte_counter[b] += 1
    end
  end
  byte_counter
end
begin
  starts = Time.now

  3.times{
    count_bytes('./data/file2.txt')
  }
  puts "Sync version took #{Time.now - starts}"
end

begin
  starts = Time.now
  guards = 3.times.map{
    fibril{
      fasync.count_bytes('./data/file2.txt')
    }
  }

  await(*guards){
    puts "Fibril took #{Time.now - starts}"
  }
end
