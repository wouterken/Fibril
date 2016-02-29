##
# The Fibril event loop.
# Requiring this file will execute all code between the require statement and EOF inside a fibril before exiting.
#
#  Ideal for scripts that need to use cooperative multitasking without having to wrap in an extra fibril simply to
# start the loop
##
require_relative '../fibril'
require 'pry'

call_stack = caller
filename   = call_stack[0][/(.*?(?=\:)):(\d+)/,1]
linenumber = call_stack[0][/(.*?(?=\:)):(\d+)/,2].to_i
lines = IO.read(filename).split("\n")[linenumber..-1]

$LOAD_PATH << '.'
fibril{ eval lines.join("\n") }
exit(0)
