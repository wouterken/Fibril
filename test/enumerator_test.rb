require 'test_helper'

describe Enumerator do
  it "can execute multiple enumerables in parallel" do
    result = []
    fibril{
      [1,2,3].each.fibril do |i|
        result << i
      end

      [4,5,6].each.fibril do |i|
        result << i
      end
    }
    assert_equal result, [1,4,2,5,3,6]
  end

  it "can execute a single enumerable in parallel" do
    result = []
    fibril{
      [1,2,3,4,5,6].each.n_fibrils(2) do |i|
        async.sleep(0.1) if (i % 2).zero?
        result << i
      end
    }
    assert_equal result, [1,3,5,2,4,6]
  end

  it "allows enumerated selections to be awaited" do
    result = result2 = nil
    fibril{
      result = await([1,2,3,4,5,6].select.n_fibrils(2) do |i|
        (i % 2).zero?
      end)
      result2 = await([1,2,3,4,5,6].select.fibril do |i|
        !(i % 3).zero?
      end)
    }
    assert_equal result, [2,4,6]
    assert_equal result2, [1,2,4,5]
  end

  it "allows enumerated mappings to be awaited" do
    result = result2 = nil
    fibril{
      result = await([1,2,3,4,5,6].map.n_fibrils(2) do |i|
        i * 3
      end)
      result2 = await([1,2,3,4,5,6].map.fibril do |i|
        i * 2
      end)
    }
    assert_equal result, [3,6,9,12,15,18]
    assert_equal result2, [2,4,6,8,10,12]
  end

end