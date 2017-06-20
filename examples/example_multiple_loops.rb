require 'fibril/loop'
require 'net/http'

def print_inline(lines, clear=true)
  puts lines
  system("tput cuu #{lines.length}") if clear
end

###
# Calculate fibonacci numbers up until a limit
##
fibril(:fibonacci) do
  variables.fib0, variables.fib1 = variables.fib1 || 1, variables.fib0.to_i + (variables.fib1 || 1)
end.until{ variables.fib0 > 1000_000_000_000_000_000_000 }


###
# Calculate primes up until a limit
##
fibril do
  limit = 500
  primes = [false] + ([true] * (limit - 1))
  primes.each.with_index(1).tick(:primes).map do |prime, i|
    prime ? (mult = i) : next
    variables.prime = variables.prime ? variables.prime + ", #{i}" : "#{i}"
    primes[(mult += i) - 1] = false while mult <= limit - i
    variables.prime
  end
end

##
# Make an HTTP request
##
fibril(:http) do
  url = URI.parse('http://www.example.com/index.html')
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.async.start(url.host, url.port) {|http|
    http.request(req)
  }
  variables.http_response_code = res.code
end

##
# Make an HTTP request
##
fibril(:http2) do
  url = URI.parse('http://www.google.com')
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.async.start(url.host, url.port) {|http|
    http.request(req)
  }
  variables.http_response_code2 = res.code
end

##
# Print status of above currently executing fibrils above
##
fibril(:print_loop){
  print_inline [
    "Fibonacci: #{variables.fib1}",
    "Prime: #{variables.prime.to_s[-18..-1]}",
    "HTTP Response code (example.com): #{variables.http_response_code}",
    "HTTP Response code (google.com): #{variables.http_response_code2}"
  ]
}.until(:fibonacci, :primes, :http)

##
# Print final result status after all fibrils have completed
##
await(:print_loop){
  print_inline [
    "Fibonacci: #{variables.fib1}",
    "Prime: #{variables.prime.to_s[-18..-1]}",
    "HTTP Response code (example.com): #{await :http}",
    "HTTP Response code (google.com): #{await :http2}",
    "Finished!"
  ], false
}
