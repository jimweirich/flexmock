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

class TestNaming < Test::Unit::TestCase
  def test_name
    m = FlexMock.new("m")
    assert_equal "m", m.mock_name
  end

  def test_name_in_no_handler_found_error
    m = FlexMock.new("mmm")
    ex = assert_raises(Test::Unit::AssertionFailedError) {
      m.should_receive(:xx).with(1)
      m.xx(2)
    }
    assert_match(/'mmm'/, ex.message)
  end

  def test_name_in_received_count_error
    m = FlexMock.new("mmm")
    ex = assert_raises(Test::Unit::AssertionFailedError) {
      m.should_receive(:xx).once
      m.mock_verify
    }
   assert_match(/'mmm'/, ex.message)
  end

  def test_naming_with_use
    FlexMock.use("blah") do |m|
      assert_equal "blah", m.mock_name
    end
  end

  def test_naming_with_multiple_mocks_in_use
    FlexMock.use("blah", "yuk") do |a, b|
      assert_equal "blah", a.mock_name
      assert_equal "yuk",  b.mock_name
    end
  end
end
