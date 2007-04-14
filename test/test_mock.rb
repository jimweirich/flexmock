#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/unit'
require 'flexmock'

class TestFlexMock < Test::Unit::TestCase
  def setup
    @mock = FlexMock.new
  end

  def test_handle
    args = nil
    @mock.mock_handle(:hi) { |a, b| args = [a,b] }
    @mock.hi(1,2)
    assert_equal [1,2], args
  end

  def test_handle_no_block
    @mock.mock_handle(:blip)
    @mock.blip
    assert true, "just checking for failures"
  end

  def test_called_with_block
    called = false
    @mock.mock_handle(:blip) { |block| block.call }
    @mock.blip { called = true }
    assert called, "Block to blip should be called"
  end

  def test_return_value
    @mock.mock_handle(:blip) { 10 }
    assert_equal 10, @mock.blip
  end

  def test_handle_missing_method
    expected_error = (VERSION >= "1.8.0") ? NoMethodError : NameError
    ex = assert_raises(expected_error) {
      @mock.not_defined
    }
    assert_match(/not_defined/, ex.message)
  end

  def test_ignore_missing_method
    @mock.mock_ignore_missing
    @mock.blip
    assert true, "just checking for failures"
  end

  def test_good_counts
    @mock.mock_handle(:blip, 3)
    @mock.blip
    @mock.blip
    @mock.blip
    @mock.mock_verify
  end

  def test_bad_counts
    @mock.mock_handle(:blip, 3)
    @mock.blip
    @mock.blip
    begin
      @mock.mock_verify
    rescue Test::Unit::AssertionFailedError => err
    end
    assert_not_nil err
  end

  def test_undetermined_counts
    FlexMock.use('fs') { |m|
      m.mock_handle(:blip)
      m.blip
      m.blip
      m.blip
    }
  end

  def test_zero_counts
    assert_raises(Test::Unit::AssertionFailedError) do
      FlexMock.use { |m|
        m.mock_handle(:blip, 0)
        m.blip
      }
    end
  end

  def test_file_io_with_use
    file = FlexMock.use do |m|
      filedata = ["line 1", "line 2"]
      m.mock_handle(:gets, 3) { filedata.shift }
      assert_equal 2, count_lines(m)
    end
  end

  def count_lines(stream)
    result = 0
    while line = stream.gets
      result += 1
    end
    result    
  end

  def test_use
    assert_raises(Test::Unit::AssertionFailedError) {
      FlexMock.use do |m|
	m.mock_handle(:blip, 2)
	m.blip
      end
    }
  end

  def test_failures_during_use
    ex = assert_raises(NameError) {
      FlexMock.use do |m|
	m.mock_handle(:blip, 2)
	xyz
      end
    }
    assert_match(/undefined local variable or method/, ex.message)
  end

  def test_sequential_values
    values = [1,4,9,16]
    @mock.mock_handle(:get) { values.shift }
    assert_equal 1, @mock.get
    assert_equal 4, @mock.get
    assert_equal 9, @mock.get
    assert_equal 16, @mock.get
  end
  
  def test_respond_to_returns_false_for_non_handled_methods
    assert(!@mock.respond_to?(:blah), "should not respond to blah")
  end

  def test_respond_to_returns_true_for_explicit_methods
    @mock.mock_handle(:xyz)
    assert(@mock.respond_to?(:xyz), "should respond to test")
  end

  def test_respond_to_returns_true_for_missing_methods_when_ignoring_missing
    @mock.mock_ignore_missing
    assert(@mock.respond_to?(:yada), "should respond to yada now")
  end

  def test_respond_to_returns_true_for_missing_methods_when_ignoring_missing_using_should
    @mock.should_ignore_missing
    assert(@mock.respond_to?(:yada), "should respond to yada now")
  end

  def test_method_proc_raises_error_on_unknown
    assert_raises(NameError) {
      @mock.method(:xyzzy)
    }
  end

  def test_method_returns_callable_proc
    got_it = false
    @mock.mock_handle(:xyzzy) { got_it = true }
    method_proc = @mock.method(:xyzzy)
    assert_not_nil method_proc
    method_proc.call
    assert(got_it, "method proc should run")
  end

  def test_method_returns_do_nothing_proc_for_missing_methods
    @mock.mock_ignore_missing
    method_proc = @mock.method(:plugh)
    assert_not_nil method_proc
    method_proc.call
  end
end
