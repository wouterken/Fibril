require_relative "../lib/fibril/loop"
##
# Example non blocking IO wrapper for Redis IO
##

class FileIOWrapper < Fibril::NonBlockingIOWrapper
  def initialize(file_name)
    super{ lines = IO.readlines(file_name); lines.each(&receive) }
  end
end

io_wrapper = FileIOWrapper.new('./data/file.txt')
io_wrapper2 = FileIOWrapper.new('./data/file2.txt')


$i = 0
def read_stuff(wrapper)
  wrapper.await
  $i += 1
end

fibril.read_stuff(io_wrapper).loop(10000)

fibril{
  io_wrapper2.await
  $i += 1
}.loop(10000)

fibril{
  print "\rI have read #{$i} lines"
}.until{ $i >= 20000 }


# lines1 = File.readlines('./data/file.txt')
# lines2 = File.readlines('./data/file2.txt')

# starts = Time.now
# i = 0
# lines1.each do |line|
#   i += 1
#   print "\rI have read #{i} lines"
#   break if i >= 10000
# end
# lines2.each do |line|
#   i += 1
#   print "\rI have read #{i} lines"
#   break if i >= 20000
# end
# ends = Time.now
# puts "Sync version took #{ends - starts}"
