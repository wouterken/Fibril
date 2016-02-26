require_relative "../lib/fibril/loop"


fibril{
  [1,3,5].async.each do |i|
    print "#{i}:"
    #tick
  end
}

fibril{
  [2,4,6].async.each do |i|
    print "#{i}:"
    #tick
  end
}

fibril{
  3.times{
    print "\n"
    #tick
  }
}
