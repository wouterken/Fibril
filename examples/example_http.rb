require_relative "../lib/fibril/loop"

def get_response_code(url, async=false)
  url = URI.parse(url)
  req = Net::HTTP::Get.new(url.to_s)
  res = async ?
    Net::HTTP.async.start(url.host, url.port) {|http|
      http.request(req)
    }
  : Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
  variables.http_response_code2 = res.code
end



Fibril.profile(:sync_http){
  get_response_code('http://www.google.com')
  get_response_code('http://nz.news.yahoo.com/')
  get_response_code('http://github.com')
  get_response_code('http://www.engadget.com')
  get_response_code('http://localhost:4000')
}

part_one = fibril{
  starts = Time.now
  fibril(:google).get_response_code('http://www.google.com', true)
  fibril(:engadget).get_response_code('http://www.engadget.com', true)
  fibril(:yahoo).get_response_code('http://nz.news.yahoo.com/', true)
  fibril(:github).get_response_code('http://github.com',true)
  fibril(:local).get_response_code('http://localhost:4000',true)
  fibril{
    puts "#{await(:google, :yahoo, :github, :engadget, :local)}"
    puts "Async v1 took #{Time.now - starts}"
  }
}

await(part_one){
  start2 = Time.now
  fibril(:a_engadget){
    async.get_response_code('http://www.engadget.com')
  }
  fibril(:a_google){
    async.get_response_code('http://www.google.com')
  }
  fibril(:a_yahoo){
    async.get_response_code('http://nz.news.yahoo.com/')
  }
  fibril(:a_github){
    async.get_response_code('http://github.com')
  }
  fibril(:a_local){
    async.get_response_code('http://localhost:4000')
  }
  await(:a_google, :a_yahoo, :a_github, :a_engadget, :a_local){|google, yahoo, github, engadget, local|
    puts "#{[google, yahoo, github, engadget, local]}"
    puts "Async v2 took #{Time.now - start2}"
  }
}