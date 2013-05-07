#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require "test/test_setup"

require "flexmock/base"
require "flexmock/test_unit"

class TestFlexmockTestUnit < Test::Unit::TestCase
  def teardown
    failed = false
    begin
      super
    rescue Exception => ex
      failed = true
    end
    assert_equal @should_fail, failed, "Expected failed to be #{@should_fail}"
  end

  # This test should pass.
  def test_can_create_mocks
    m = flexmock("mock")
    m.should_receive(:hi).once
    m.hi
    @should_fail = false
  end

  # This test should fail during teardown.
  def test_should_fail__mocks_are_auto_verified
    m = flexmock("mock")
    m.should_receive(:hi).once
    @should_fail = true
  end
end
