require 'test_helper'

describe Fibril::FFuture do
  it "can execute future code in a separate fork" do
    fut = Fibril::FFuture.new{
      5 + 10
    }
    assert_equal fut.await, 15
  end

  it "can return any serializable data structure" do
    relatively_complex = {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    fut = Fibril::FFuture.new{
      {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    }
    assert_equal fut.await, relatively_complex
  end

  it "can await multiple ffutures" do
    result = nil
    fibril{
      result = await_all(Fibril::FFuture.new{3}, Fibril::FFuture.new{4})
    }
    assert_equal [3,4], result
  end

  it "does not share memory" do
    result = -1
    fut = Fibril::FFuture.new{
      result = 10
    }
    assert_equal result, -1
  end
end