#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/test_setup'

class BasedPartialsTest < Test::Unit::TestCase
  include FlexMock::TestCase

  def setup
    super
    FlexMock.partials_are_based = true
  end

  def teardown
    FlexMock.partials_are_based = false
    super
  end

  class Dog
    def bark
      :woof
    end
  end

  def test_based_partials_allow_stubbing_defined_methods
    dog = Dog.new
    flexmock(dog).should_receive(:bark => :mock_value)
    assert_equal :mock_value, dog.bark
  end

  def test_based_partials_disallow_stubbing_undefined_methods
    dog = Dog.new
    assert_raise(NoMethodError, /cannot stub.*wag.*explicitly/) do
      flexmock(dog).should_receive(:wag => :mock_value)
    end
  end

  def test_based_partials_allow_explicitly_stubbing_undefined_methods
    dog = Dog.new
    flexmock(dog).should_receive(:wag).explicitly.and_return(:mock_value)
  end

end
