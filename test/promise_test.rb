require 'test_helper'

describe Fibril::Promise do
  it "can execute promise code in a separate thread" do
    start = Time.now
    prom = Fibril::Promise.new{
      sleep 1
      5 + 10
    }
    ends = Time.now
    assert ends - start < 1
    assert_equal prom.await, 15
  end

  it "returns any promise result" do
    relatively_complex = {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    prom = Fibril::Promise.new{
      {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    }
    assert_equal prom.await, relatively_complex
  end

  it "can await multiple promises" do
    result = nil
    fibril{
      result = await_all(Fibril::Promise.new{3}, Fibril::Promise.new{4})
    }
    assert_equal [3,4], result
  end

  it "does shares memory" do
    result = -1
    prom = Fibril::Promise.new{
      result = 10
    }
    assert_equal result, -1
    prom.await
    assert_equal result, 10
  end
end