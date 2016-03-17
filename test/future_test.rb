require 'test_helper'

describe Fibril::Future do
  it "can execute future code in a separate thread" do
    start = Time.now
    fut = Fibril::Future.new{
      sleep 1
      5 + 10
    }
    ends = Time.now
    assert ends - start < 1
    assert_equal fut.await, 15
  end

  it "returns any future result" do
    relatively_complex = {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    fut = Fibril::Future.new{
      {
      hello: {
        world: [1,2,3.0, "test", :symbol, true]
      }
    }
    }
    assert_equal fut.await, relatively_complex
  end

  it "can await multiple futures" do
    result = nil
    fibril{
      result = await_all(Fibril::Future.new{3}, Fibril::Future.new{4})
    }
    assert_equal [3,4], result
  end

  it "does shares memory" do
    result = -1
    fut = Fibril::Future.new{
      result = 10
    }
    assert_equal result, -1
    fut.await
    assert_equal result, 10
  end
end