require "test/unit"
require "ambit"

Ambit::trace if ENV['AMBIT_TRACE']


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

  def test_nested_default
    a = Ambit::choose(0..5)
    b = Ambit::choose(0..5)
    Ambit::fail! unless a + b == 7
    assert(a+b == 7)
    Ambit::clear!
  end

  def test_nested_private
    nd = Ambit::Generator.new
    a = nd.choose(0..5)
    b = nd.choose(0..5)
    nd.fail! unless a + b == 7
    assert(a+b == 7)
    nd.clear!
  end

  def test_toplevel_fail
    assert_raise Ambit::ChoicesExhausted do
      Ambit::fail!
    end
  end

  def test_clear
    Ambit::choose(0..10)
    Ambit::choose(0..1)
    Ambit::clear!
    assert_raise Ambit::ChoicesExhausted do
      Ambit::fail!
    end
  end

  def test_mark_cut
    nd = Ambit::Generator.new
    i = 0;
    nd.choose(1..3)             # just to have an earlier choice
    nd.mark
    b = nd.choose([1, 2, 3])
    c = nd.choose([1, 2, 3])
    i+=1
    if b == 2 && c == 2
      nd.cut!
    end
    nd.fail!
  rescue Ambit::ChoicesExhausted
    assert(i==15)
  end

  def test_unmark_all
    Ambit::choose(1..3)             # just to have an earlier choice
    Ambit::mark
    b = Ambit::choose(1..3)
    Ambit::unmark_all!
    # if we hadn't unmarked here, a cut would leave us choices
    Ambit::cut!
    assert_raise Ambit::ChoicesExhausted do
      Ambit::fail!
    end
  end

  def test_unmark
    Ambit::choose(1..3)             # just to have an earlier choice
    Ambit::mark
    Ambit::unmark!
    # if we hadn't unmarked here, a cut would leave us choices
    Ambit::cut!
    assert_raise Ambit::ChoicesExhausted do
      Ambit::fail!
    end
  end

end
