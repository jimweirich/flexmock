#!/usr/bin/env ruby

require 'test/test_setup'
require 'flexmock/test_unit_assert_spy_called'

class AssertSpyCalledTest < Test::Unit::TestCase
  include FlexMock::TestCase

  class FooBar
    def foo
    end
    def bar
    end
  end

  def setup
    super
    @spy = flexmock(:on, FooBar)
  end

  def spy
    @spy
  end

  def test_assert_detects_basic_call
    spy.foo
    assert_spy_called spy, :foo
  end

  def test_assert_detects_basic_call_with_args
    spy.foo(1,2)
    assert_spy_called spy, :foo, 1, 2
  end

  def test_assert_rejects_incorrect_args
    spy.foo(1,2)
    messages = assert_fails(/^expected foo\(1, 3\) to be called on <FlexMock:AssertSpyCalledTest::FooBar Mock>/i) do
      assert_spy_called spy, :foo, 1, 3
    end
  end

  def test_assert_detects_multiple_calls
    spy.foo
    spy.foo
    spy.foo
    assert_spy_called spy, {times: 3}, :foo
  end

  def test_assert_rejects_incorrect_type
    spy.foo
    spy.foo
    assert_fails(/^expected foo\(\) to be called on <FlexMock:AssertSpyCalledTest::FooBar Mock> 3 times/i) do
      assert_spy_called spy, {times: 3}, :foo
    end
  end

  def test_assert_detects_blocks
    spy.foo { }
    spy.bar
    assert_spy_called spy, {with_block: true}, :foo
    assert_spy_called spy, {with_block: true, times: 0}, :bar
  end

  def test_assert_detects_any_args
    spy.foo
    spy.foo(1)
    spy.foo("HI")
    spy.foo("Hello", "World", 10, options: true)
    assert_spy_called spy, {times: 4, any_args: true}, :foo
  end

  def test_assert_rejects_bad_count_on_any_args
    spy.foo
    assert_fails(/^expected foo\(\.\.\.\) to be called on <FlexMock:AssertSpyCalledTest::FooBar Mock> twice/i) do
      assert_spy_called spy, {times: 2, any_args: true}, :foo
    end
  end

  private

  def assert_fails(message_pattern)
     ex = assert_raises(FlexMock.framework_adapter.assertion_failed_error) do
      yield
    end
    assert_match(message_pattern, ex.message)
    ex
  end

end
