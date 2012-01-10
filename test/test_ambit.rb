require "test/unit"
require "nondeterminism"

class TestNondeterminism < Test::Unit::TestCase

  def test_simple_default
    x = ND::choose([1, 2])
    ND::require x.even?
    assert(x == 2)
    ND::clear!
  end

  def test_simple_private
    nd = Nondeterminism::Generator.new
    x = nd.choose([1, 2])
    nd.require x.even?
    assert(x == 2)
  end

  def test_nested
    a = ND::choose(0..5)
    b = ND::choose(0..5)
    ND::fail! unless a + b == 7
    assert(a+b == 7)
    ND::clear!
  end

  def test_fail
    assert_raise Nondeterminism::ChoicesExhausted do
      ND::fail!
    end
  end
  
end
