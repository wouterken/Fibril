require 'test_helper'

class TestIOWrapper < Fibril::NonBlockingIOWrapper
  def initialize
    super{
      1000.times do |i|
        receive(i)
      end
    }
  end
end


describe Fibril::NonBlockingIOWrapper do
  it "can receive data from Non blocking IO wrapper" do
    wrapper = TestIOWrapper.new
    result = 0
    fibril{
      fibril{
        result += wrapper.await
      }.loop(300)
    }

    assert_equal result, (1...300).inject(:+)
  end

  it "multiple handlers can receive data from Non blocking IO wrapper" do
    wrapper = TestIOWrapper.new
    result = 0
    fibril{
      fibril{
        value =  wrapper.await
        result += value
      }.loop(300)

      fibril{
        value =  wrapper.await
        result += value
      }.loop(300)
    }

    assert_equal result, (1...600).inject(:+)
  end
end