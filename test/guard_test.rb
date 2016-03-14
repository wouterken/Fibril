require 'test_helper'

describe Fibril::Guard do

  it "creates a guard when spawning a fibril within a loop" do
    assert_kind_of = ->(v, t){ assert v.kind_of? t}
    Fibril{
       assert_kind_of[fibril{}, Fibril::Guard]
    }
  end

  it "allows a guard to be awaited inside another fibril" do
    result = []

    Fibril{

      g1 = fibril{
        result << 1
        async.sleep 0.5
      }

      g2 = fibril{
        await(g1)
        result << 2
      }

      g3 = fibril{
        result << 3
      }

    }

    assert_equal result, [1,3,2]
  end

  it "allows a guard to be awaited inside the main fibril" do
    result = []
    Fibril{
      g1 = fibril{
        result << 1
        async.sleep 0.5
      }

      await(g1){
        result << 2
      }
    }
    assert_equal result, [1,2]
  end

  it "allows many guards to be awaited at once" do
    result = []
    Fibril{
      g1 = fibril{
        result << 1
        async.sleep 0.5
      }

      g2 = fibril{
        result << 2
        async.sleep 0.5
      }

      await(g1, g2){
        result << 3
      }
    }
    assert_equal result, [1,2,3]
  end

  it "allows guards to be awaited out of order" do
    result = []
    Fibril{
      g1 = fibril{
        async.sleep 0.5
        result << 1
      }

      g2 = fibril{
        result << 2
      }

      await(g2){
        result << 3
        await(g1){
          result << 4
        }
      }
    }
    assert_equal result, [2,3,1,4]
  end

  it "returns result of fibril when awaiting guard in both call and block form" do
    assert_equal = self.method(:assert_equal)
    Fibril{
      g1 = fibril{
        42
      }

      fibril(:g2){
        - 2 ** 3
      }

      assert_equal[await(g1, :g2), [42, -8]]

      await(g1, guard.g2) do |r1, r2|
        assert_equal[[r1, r2], [42, -8]]
      end
    }
  end

  it "allows referring to guard by name" do
    assert_equal = self.method(:assert_equal)

    result = []
    Fibril{
      fibril(:g1){
        result << 1
        async.sleep 0.5
      }

      fibril(:g2){
        result << 2
        async.sleep 0.5
      }

      g3 = fibril(:g3){}

      await(:g1, :g2, g3){
        result << 3
      }

      assert_equal.call g3, guard.g3
    }
    assert_equal.call result, [1,2,3]
  end

end