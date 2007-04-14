#!/usr/bin/env ruby
#
#  Created by Jim Weirich on 2007-04-11.
#  Copyright (c) 2007. All rights reserved.

require "test/unit"
require "flexmock"

class TestFlexmockDefaultFrameworkAdapter < Test::Unit::TestCase
  def setup
    @adapter = FlexMock::DefaultFrameworkAdapter.new
  end

  def test_assert_block_raises_exception  
    ex = assert_raise(FlexMock::DefaultFrameworkAdapter::AssertionFailedError) { 
      @adapter.assert_block("failure message") { false }
    }
  end

  def test_assert_block_doesnt_raise_exception
    @adapter.assert_block("failure message") { true }
  end
  
  def test_assert_equal_doesnt_raise_exception
    @adapter.assert_equal("a", "a", "no message")
  end
  
  def test_assert_equal_can_fail
    ex = assert_raise(FlexMock::DefaultFrameworkAdapter::AssertionFailedError) {
      @adapter.assert_equal("a", "b", "a should not equal b")
    }
  end
end