require 'fibril/loop'

fibril{
  [1,3,5].each do |i|
    print i.to_s+?:
    tick
  end
}

fibril{
  [2,4,6].each do |i|
    print i.to_s
    tick
  end
}

fibril{
  3.times{
    print "\n"
    tick
  }
}
