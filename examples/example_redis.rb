require_relative "../lib/fibril/loop"
require 'redis'
##
# Example non blocking IO wrapper for Redis IO
##
class RedisPubSubWrapper < Fibril::NonBlockingIOWrapper
  attr_accessor :pub, :sub, :channel_name

  def initialize(channel_name)
    self.channel_name = channel_name
    self.pub, self.sub = Redis.new, Redis.new
    super{ sub.subscribe(channel_name){|on| on.message(&receive) }}
  end

  def publish(msg)
    pub.publish(channel_name, msg)
  end
end


##
#
# Example:
#
##

def publish(redis)
  async.sleep 0.1
  puts "SEND: #{'a message 1'}"
  redis.async.publish('a message 1')
  puts "SEND: #{'a message 2'}"
  redis.async.publish('a message 2')
  puts "SEND: #{'a message 3'}"
  redis.async.publish('a message 3')
end

def recv(redis)
  _channel, message = redis.await
  puts "RECV: #{message}"
end

redis = RedisPubSubWrapper.new 'test'
fibril.publish(redis).loop(3)
fibril.recv(redis).loop(9)


# fibril.send
# fibril.recv.loop(3)