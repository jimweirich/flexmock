#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/test_setup'

class ExpectationDescriptionTest < Test::Unit::TestCase
  include FlexMock::TestCase

  def setup
    @mock = flexmock("mock")
    @exp = FlexMock::Expectation.new(@mock, :foo, "file.rb:3")
  end

  def test_basic_description
    assert_equal "should_receive(:foo)", @exp.description
  end

  def test_with_no_args
    @exp.with()
    assert_equal "should_receive(:foo).with()", @exp.description
  end

  def test_with_simple_args
    @exp.with(1, "HI")
    assert_equal "should_receive(:foo).with(1, \"HI\")", @exp.description
  end

  def test_with_never
    @exp.never
    assert_equal "should_receive(:foo).never", @exp.description
  end

  def test_with_once
    @exp.once
    assert_equal "should_receive(:foo).once", @exp.description
  end

  def test_with_twice
    @exp.twice
    assert_equal "should_receive(:foo).twice", @exp.description
  end

  def test_with_3
    @exp.times(3)
    assert_equal "should_receive(:foo).times(3)", @exp.description
  end

  def test_with_at_least_once
    @exp.at_least.once
    assert_equal "should_receive(:foo).at_least.once", @exp.description
  end

  def test_with_at_least_10
    @exp.at_least.times(10)
    assert_equal "should_receive(:foo).at_least.times(10)", @exp.description
  end

  def test_with_at_most_once
    @exp.at_most.once
    assert_equal "should_receive(:foo).at_most.once", @exp.description
  end

  def test_with_zero_or_more_times
    @exp.at_most.zero_or_more_times
    assert_equal "should_receive(:foo).zero_or_more_times", @exp.description
  end

  def test_with_at_least_1_at_most_10
    @exp.at_least.once.at_most.times(10)
    assert_equal "should_receive(:foo).at_least.once.at_most.times(10)", @exp.description
  end
end
