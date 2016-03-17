require_relative "../lib/fibril/loop"

[1,3,5].each.fibril do |i|
  print "#{i},"
end

[2,4,6].each.fibril do |i|
  print "#{i},"
end
