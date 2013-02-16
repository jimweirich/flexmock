#!/usr/bin/env ruby

require 'test/test_setup'

class TestSpys < Test::Unit::TestCase
  include FlexMock::TestCase

  class FooBar
    def foo
      :foofoo
    end
    def bar
    end
  end

  def setup
    super
    @spy = flexmock(:on, FooBar)
  end

  def test_spy_detects_simple_call
    @spy.foo
    assert_spy_called @spy, :foo
  end

  def test_spy_detects_simple_call_ignoring_args
    @spy.foo(1)
    assert_spy_called @spy, :foo, :_
  end

  def test_spy_rejects_a_never_made_call
    @spy.foo
    assert_spy_not_called @spy, :bar
  end

  def test_spy_detects_call_with_literal_arg
    @spy.foo(1)
    assert_spy_called @spy, :foo, 1
  end

  def test_spy_detects_call_with_class_arg
    @spy.foo(1)
    assert_spy_called @spy, :foo, Integer
  end

  def test_spy_rejects_call_with_non_matching_literal_arg
    @spy.foo(2)
    assert_spy_not_called @spy, :foo, 1
  end

  def test_spy_detects_call_with_multiple_arguments
    @spy.foo(1, "HI", :foo)
    assert_spy_called @spy, :foo, /1/, "HI", Symbol
  end

  def test_spy_detects_multiple_calls_with_different_arguments
    @spy.foo(1)
    @spy.foo(1)
    assert_spy_called @spy, {:times => 2}, :foo, 1
  end

  def test_spy_rejects_if_times_options_not_matching
    @spy.foo(1)
    @spy.foo(1)
    assert_spy_not_called @spy, {:times => 1}, :foo, 1
  end

  def test_spy_detects_a_block
    @spy.foo { }
    assert_spy_called @spy, :foo, Proc
  end

  def test_spy_rejects_a_block
    @spy.foo { }
    assert_spy_not_called @spy, {:with_block => false}, :foo
  end

  def test_spy_detects_a_missing_block
    @spy.foo
    assert_spy_called @spy, {:with_block => false}, :foo
  end

  def test_spy_rejects_a_missing_block
    @spy.foo
    assert_spy_not_called @spy, :foo, Proc
  end

  def test_spy_ignores_block
    @spy.foo { }
    assert_spy_called @spy, :foo, Proc
  end

  def test_spy_accepts_correct_additional_validations
    @spy.foo(2)
    is_even = proc { |n| assert_equal 0, n%2 }
    assert_spy_called @spy, { :and => is_even }, :foo, Integer
  end

  def test_spy_accepts_multiple_additional_validations_first_failing
    @spy.foo(4)
    is_two  = proc { |n| assert_equal 2, n }
    is_even = proc { |n| assert_equal 0, n%2 }
    assert_failed(/2.*expected but was.*4/mi) do
      assert_spy_called @spy, { :and => [is_two, is_even] }, :foo, Integer
    end
  end

  def test_spy_accepts_multiple_additional_validations_second_failing
    @spy.foo(4)
    is_even = proc { |n| assert_equal 0, n%2 }
    is_two  = proc { |n| assert_equal 2, n }
    assert_failed(/2.*expected but was.*4/mi) do
      assert_spy_called @spy, { :and => [is_even, is_two] }, :foo, Integer
    end
  end

  def test_spy_rejects_incorrect_additional_validations
    @spy.foo(3)
    is_even = proc { |n| assert_equal 0, n%2 }
    assert_failed(/0.*expected but was.*1/mi) do
      assert_spy_called @spy, { :and => is_even }, :foo, Integer
    end
  end

  def test_spy_selectively_applies_additional_validations
    @spy.foo(2)
    @spy.foo(3)
    @spy.foo(4)
    is_even = proc { |n| assert_equal 0, n%2 }
    assert_failed(/0.*expected but was.*1/mi) do
      assert_spy_called @spy, { :and => is_even, :on => 2 }, :foo, Integer
    end
  end

  def assert_failed(message_pattern)
    failed = false
    begin
      yield
    rescue assertion_failed_error => ex
      failed = true
      assert_match message_pattern, ex.message
    end
    assert(failed, "Expected block to fail")
  end

  def test_spy_methods_can_be_stubbed
    @spy.should_receive(:foo).and_return(:hi)
    result = @spy.foo
    assert_equal result, :hi
    assert_spy_called @spy, :foo
  end

  def test_spy_cannot_see_normal_methods
    foo = FooBar.new
    flexmock(foo)
    assert_equal :foofoo, foo.foo
    assert_spy_not_called foo, :foo
  end

  def test_spy_cannot_see_normal_methods2
    foo = FooBar.new
    flexmock(foo).should_receive(:foo).pass_thru
    assert_equal :foofoo, foo.foo
    assert_spy_called foo, :foo
  end

  def test_calling_non_spy_base_methods_is_an_error
    assert_raise(NoMethodError) do
      @spy.baz
    end
  end

  def test_cant_put_expectations_on_non_base_class_methodsx
    ex = assert_raise(NoMethodError) do
      @spy.should_receive(:baz).and_return(:bar)
    end
    assert_match(/cannot stub.*defined.*base.*class/i, ex.message)
    assert_match(/method: +baz/i, ex.message)
    assert_match(/base class: +TestSpys::FooBar/i, ex.message)
  end

  def test_cant_put_expectations_on_non_base_class_methods_unless_explicit
    @spy.should_receive(:baz).explicitly.and_return(:bar)
    @spy.baz
    assert_spy_called @spy, :baz
  end

  def test_ok_to_use_explicit_even_when_its_not_needed
    @spy.should_receive(:foo).explicitly.and_return(:bar)
    @spy.foo
    assert_spy_called @spy, :foo
  end

  def test_can_spy_on_partial_mocks
    @foo = FooBar.new
    @spy = flexmock(@foo)
    @foo.should_receive(:foo => :baz)
    result = @foo.foo
    assert_equal :baz, result
    assert_spy_called @foo, :foo
  end

  def test_can_spy_on_class_defined_methods
    flexmock(FooBar).should_receive(:new).and_return(:dummy)
    FooBar.new
    assert_spy_called FooBar, :new
  end

  def test_can_spy_on_regular_mocks
    mock = flexmock("regular mock")
    mock.should_receive(:foo => :bar)
    mock.foo
    assert_spy_called mock, :foo
  end
end
