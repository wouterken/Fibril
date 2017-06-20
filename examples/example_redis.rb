require 'fibril/loop'
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
  $total_invocation_count ||= 0
  $total_invocation_count += 1
  async.sleep 0.1
  puts "SEND: #{"M1:I#{$total_invocation_count}"}"
  redis.async.publish("M1:I#{$total_invocation_count}")
  puts "SEND: #{"M2:I#{$total_invocation_count}"}"
  redis.async.publish("M2:I#{$total_invocation_count}")
  puts "SEND: #{"M3:I#{$total_invocation_count}"}"
  redis.async.publish("M3:I#{$total_invocation_count}")
end

def recv(redis)
  $total_recv_count ||= 0
  $total_recv_count += 1
  _channel, message = redis.await
  puts "RECV: #{message}: total: #{$total_recv_count}"
end

redis = RedisPubSubWrapper.new 'test'
fibril.publish(redis).loop(10)
fibril.recv(redis).loop(30)

