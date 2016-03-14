require 'test_helper'

describe Fibril::Guard do
  it "can loop fibrils multiple times" do
    result = 2

    fibril{
      fibril{
        result *= 2
      }.loop(3)
    }

    assert_equal 2 ** 4, result
  end

  it "can loop fibrils while a conditional is true" do
    result = 2

    fibril{
      fibril{
        result *= 2
      }.while{ result < 100 }
    }

    assert_equal 2 ** 7, result
  end

  it "can loop fibrils until a conditional is true" do
    result = 2

    fibril{
      fibril{
        result *= 2
      }.until{ result > 100 }
    }
    assert_equal 2 ** 7, result
  end
end