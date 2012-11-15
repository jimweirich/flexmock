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
    assert_fails(/^expected foo\(1, 3\) to be received by <FlexMock:AssertSpyCalledTest::FooBar Mock>/i) do
      assert_spy_called spy, :foo, 1, 3
    end
  end

  def test_assert_detects_multiple_calls
    spy.foo
    spy.foo
    spy.foo
    assert_spy_called spy, {:times => 3}, :foo
  end

  def test_assert_rejects_incorrect_type
    spy.foo
    spy.foo
    assert_fails(/^expected foo\(\) to be received by <FlexMock:AssertSpyCalledTest::FooBar Mock> 3 times/i) do
      assert_spy_called spy, {:times => 3}, :foo
    end
  end

  def test_assert_detects_blocks
    spy.foo { }
    spy.bar
    assert_spy_called spy, :foo, Proc
    assert_spy_called spy, :bar
  end

  def test_assert_detects_any_args
    spy.foo
    spy.foo(1)
    spy.foo("HI")
    spy.foo("Hello", "World", 10, :options => true)
    assert_spy_called spy, {:times => 4}, :foo, :_
  end

  def test_assert_rejects_bad_count_on_any_args
    spy.foo
    assert_fails(/^expected foo\(\.\.\.\) to be received by <FlexMock:AssertSpyCalledTest::FooBar Mock> twice/i) do
      assert_spy_called spy, {:times => 2}, :foo, :_
    end
  end

  def test_assert_error_lists_calls_actually_made_without_handled_by
    spy.foo
    spy.bar(1)
    ex = assert_fails(/The following messages have been received/) do
      assert_spy_called spy, :baz
    end
    assert_match(/  foo\(\)/, ex.message)
    assert_match(/  bar\(1\)/, ex.message)
    assert_no_match(/  baz\(\)/, ex.message)
    assert_no_match(/handled by/, ex.message)
  end

  def test_assert_error_lists_calls_actually_made_with_handled_by
    spy.should_receive(:foo).once
    spy.foo
    spy.bar(1)
    ex = assert_fails(/The following messages have been received/) do
      assert_spy_called spy, :baz
    end
    assert_match(/  foo\(\) matched by should_receive\(:foo\)/, ex.message)
    assert_match(/  bar\(1\)/, ex.message)
    assert_no_match(/  baz\(\)/, ex.message)
  end

  def test_assert_errors_say_no_calls_made
    assert_fails(/No messages have been received/) do
      assert_spy_called spy, :baz
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
