require_relative '../fibril'
require 'pry'

call_stack = caller
lines = IO.read(call_stack[0][/.*?(?=\:)/,0]).split("\n")

if %r{require.*".*?fibril/loop"} =~ lines[0].gsub("'",?").gsub(/\s+/,' ').strip
  $LOAD_PATH << '.'
  fibril{ eval lines[1..-1].join("\n") }
  exit(0)
end