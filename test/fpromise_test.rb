require 'test_helper'

describe Fibril::FPromise do
  it "can execute promise code in a separate fork" do
    prom = Fibril::FPromise.new{
      5 + 10
    }
    assert_equal prom.await, 15
  end

  it "can return any serializable data structure" do
    relatively_complex = {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    prom = Fibril::FPromise.new{
      {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    }
    assert_equal prom.await, relatively_complex
  end

  it "can await multiple fpromises" do
    result = nil
    fibril{
      result = await_all(Fibril::FPromise.new{3}, Fibril::FPromise.new{4})
    }
    assert_equal [3,4], result
  end

  it "does not share memory" do
    result = -1
    prom = Fibril::FPromise.new{
      result = 10
    }
    assert_equal result, -1
  end
end