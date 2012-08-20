
#!/usr/bin/env ruby

require 'test/test_setup'

class TestDemeterMocking < Test::Unit::TestCase
  include FlexMock::TestCase

  class FooBar
    def foo
    end
    def bar
    end
  end

  def setup
    super
    @spy = flexmock("spy", :spy_on, FooBar)
  end

  def test_spy_detects_simple_call
    @spy.foo
    assert @spy.flexmock_was_called_with?(:foo, nil), "foo should be detected"
  end

  def test_spy_detects_simple_call_ignoring_args
    @spy.foo(1)
    assert @spy.flexmock_was_called_with?(:foo, nil), "foo should be detected"
  end

  def test_spy_rejects_a_never_made_call
    @spy.foo
    assert ! @spy.flexmock_was_called_with?(:bar, nil), "bar should be rejected"
  end

  def test_spy_detects_call_with_literal_arg
    @spy.foo(1)
    assert @spy.flexmock_was_called_with?(:foo, [1]), "foo(1) should be detected"
  end

  def test_spy_detects_call_with_class_arg
    @spy.foo(1)
    assert @spy.flexmock_was_called_with?(:foo, [Integer]), "foo(1) should be detected"
  end

  def test_spy_rejects_call_with_non_matching_literal_arg
    @spy.foo(2)
    assert ! @spy.flexmock_was_called_with?(:foo, [1]), "foo(2) should not be detected"
  end

  def test_spy_detects_call_with_multiple_arguments
    @spy.foo(1, "HI", :foo)
    assert @spy.flexmock_was_called_with?(:foo, [/1/, "HI", Symbol]), "foo(...) should be detected"
  end

  def test_spy_detects_multiple_calls_with_different_arguments
    @spy.foo(1)
    @spy.foo(1)
    assert @spy.flexmock_was_called_with?(:foo, [1], :times => 2)
  end

  def test_spy_rejects_if_times_options_not_matching
    @spy.foo(1)
    @spy.foo(1)
    assert ! @spy.flexmock_was_called_with?(:foo, [1], :times => 1), "should not accept wrong number of calls"
  end

  def test_spy_detects_a_block
    @spy.foo { }
    assert @spy.flexmock_was_called_with?(:foo, nil, :with_block => true), "should accept a block"
  end

  def test_spy_rejects_a_block
    @spy.foo { }
    assert ! @spy.flexmock_was_called_with?(:foo, nil, :with_block => false), "should accept a block"
  end

  def test_spy_detects_a_missing_block
    @spy.foo
    assert @spy.flexmock_was_called_with?(:foo, nil, :with_block => false), "should accept a block"
  end

  def test_spy_rejects_a_missing_block
    @spy.foo
    assert ! @spy.flexmock_was_called_with?(:foo, nil, :with_block => true), "should accept a block"
  end

  def test_spy_ignores_missing_block
    @spy.foo
    assert @spy.flexmock_was_called_with?(:foo, nil), "should ignore the status of the block"
  end

  def test_spy_ignores_block
    @spy.foo { }
    assert @spy.flexmock_was_called_with?(:foo, nil), "should ignore the status of the block"
  end
end
