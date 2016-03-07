require 'test_helper'

describe Fibril::AsyncProxy do

  before do
    Kernel.define_singleton_method(:noop){}
  end

  it "intercepts calls and executes them asynchronously" do
    results = []
    fibril{
      fibril{
        results << 1
        async.sleep(0.4)
        results << 2
      }
      fibril{
        results << 3
        async.sleep(0.1)
        results << 4
      }
    }
  end

  it "forwards all arguments and blocks" do
    result = 0
    fibril{
      [1,2,3].async.each do |i|
        result += i
      end
    }
    assert_equal result, 6
  end

  it "resumes the containing fibril if possible" do
    resumed = false
    fibril{
      Kernel.async.noop
      resumed = true
    }
    assert resumed
  end
end