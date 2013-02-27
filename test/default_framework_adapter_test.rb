#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require "test/test_setup"

class TestFlexmockDefaultFrameworkAdapter < Test::Unit::TestCase
  def setup
    @adapter = FlexMock::DefaultFrameworkAdapter.new
  end

  def test_assert_block_raises_exception
    assert_raise(FlexMock::DefaultFrameworkAdapter::AssertionFailedError) {
      @adapter.make_assertion("failure message") { false }
    }
  end

  def test_make_assertion_doesnt_raise_exception
    @adapter.make_assertion("failure message") { true }
  end

  def test_make_assertion_doesnt_raise_exception
    @adapter.assert_equal("a", "a", "no message")
  end

  def test_assert_equal_can_fail
    assert_raise(FlexMock::DefaultFrameworkAdapter::AssertionFailedError) {
      @adapter.assert_equal("a", "b", "a should not equal b")
    }
  end
end
