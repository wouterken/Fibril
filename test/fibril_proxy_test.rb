require 'test_helper'

describe Fibril::FibrilProxy do

  before do
    Kernel.define_singleton_method(:noop){}
    Kernel.define_singleton_method(:get_5){ 5 }
  end

  it "intercepts calls and executes them asynchronously" do
    results = []
    fibril{
      fibril{
        results << 1
        fibril.sleep(0.4)
        results << 2
      }
      fibril{
        results << 3
        fibril.sleep(0.1)
        results << 4
      }
    }
  end

  it "shares memory" do
    result = 0
    fibril{
      [1,2,3].fibril.each do |i|
        result += i
      end
    }
    assert_equal result, 6
  end

  it "resumes the containing fibril if possible" do
    resumed = false
    fibril{
      Kernel.fibril.noop
      resumed = true
    }
    assert resumed
  end

end