require "fibril/loop"

fibril{
  [1,3,5].each do |i|
    async.print "#{i}:"
  end
}

fibril{
  [2,4,6].each do |i|
    async.print "#{i}:"
  end
}
