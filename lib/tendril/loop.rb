require_relative '../tendril'
require 'pry'

call_stack = caller
lines = IO.read(call_stack[0][/.*?(?=\:)/,0]).split("\n")

if %r{require.*".*?tendril/loop"} =~ lines[0].gsub("'",?").gsub(/\s+/,' ').strip
  $LOAD_PATH << '.'
  weave{ eval lines[1..-1].join("\n") }
  exit(0)
end