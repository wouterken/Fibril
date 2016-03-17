require 'test_helper'

describe Fibril do
  it "has a version number" do
    refute_nil ::Fibril::VERSION
  end

  it "responds to control methods" do
    assert_respond_to(Kernel, :fibril)
    assert_respond_to(Kernel, :future)
  end

  it "starts the event loop inside the first fibril" do
    refute Fibril.running
    fibril(&(->{ assert Fibril.running}).method(:call))
  end

  it "allows nested fibrils" do
    assert_queue_size = ->(size){ assert_equal Fibril.queue.size, size}
    fibril{
      fibril{
        fibril{ assert_queue_size[1] }
        fibril{ assert_queue_size[0] }
        assert_queue_size[2]
      }
      assert_queue_size[1]
    }
  end

  it "executes deterministically on synchronous fibrils" do
    exec_order = []
    fibril{
      fibril{
        exec_order << 1
        tick
        exec_order << 3
      }
      fibril{
        exec_order << 2
        tick
        exec_order << 4
      }
    }
    assert_equal exec_order, [1,2,3,4]
  end

  it "allows async portions of code to execute out of order" do
    exec_order = []
    fibril{
      fibril{
        exec_order << 1
        async.sleep 0.30
        exec_order << 3
      }
      fibril{
        exec_order << 2
        async.sleep 0.01
        exec_order << 4
      }
    }
    assert_equal [1,2,4,3], exec_order
  end

  it "has a running id sequence for fibrils" do
    start = Fibril.id_seq
    assert_fibril_id = ->(id){ assert_equal Fibril.current.id, id}
    fibril{
      fibril{
        assert_fibril_id[start + 2]
        fibril{
          assert_fibril_id[start + 4]
        }
      }
      fibril{
        assert_fibril_id[start + 3]
      }
    }
  end

  it "terminates the event loop once all fibrils have finished" do
    counter = 0
    fibril{
      fibril{
        counter += 3
        tick
        counter *= 2
      }
      fibril{
        counter += 11
        fibril{
          counter -= 6
          tick
          counter += 1
        }
        tick
        fibril{
          counter /= 0.3
          tick
          counter += counter
        }
      }
    }
    # (((((3 + 11 ) * 2) - 6) +1) / 0.3) * 2
    assert_equal 460 / 3.0, counter
    assert_equal Fibril.running, false
  end
end
