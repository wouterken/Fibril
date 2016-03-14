require 'test_helper'

describe Fibril::FAsyncProxy do

  before do
    Kernel.define_singleton_method(:noop){}
    Kernel.define_singleton_method(:get_5){ 5 }
  end

  it "intercepts calls and executes them asynchronously" do
    results = []
    fibril{
      fibril{
        results << 1
        fasync.sleep(0.4)
        results << 2
      }
      fibril{
        results << 3
        fasync.sleep(0.1)
        results << 4
      }
    }
  end

  it "does not share memory" do
    result = 0
    fibril{
      [1,2,3].fasync.each do |i|
        result += i
      end
    }
    refute_equal result, 6
  end

  it "resumes the containing fibril if possible" do
    resumed = false
    fibril{
      Kernel.fasync.noop
      resumed = true
    }
    assert resumed
  end

  it "returns values from containing fork" do
    result = nil
    fibril{
      result = Kernel.fasync.get_5
    }
    assert_equal result, 5
  end
end