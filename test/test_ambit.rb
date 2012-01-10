require "test/unit"
require "ambit"

class TestAmbit < Test::Unit::TestCase

  def test_simple_default
    x = Ambit::choose([1, 2])
    Ambit::require x.even?
    assert(x == 2)
    Ambit::clear!
  end

  def test_simple_private
    nd = Ambit::Generator.new
    x = nd.choose([1, 2])
    nd.require x.even?
    assert(x == 2)
  end

  def test_nested
    a = Ambit::choose(0..5)
    b = Ambit::choose(0..5)
    Ambit::fail! unless a + b == 7
    assert(a+b == 7)
    Ambit::clear!
  end

  def test_toplevel_fail
    assert_raise Ambit::ChoicesExhausted do
      Ambit::fail!
    end
  end
  
end
