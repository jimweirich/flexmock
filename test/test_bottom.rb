#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require "test/unit"
require "flexmock"

class BottomTest < Test::Unit::TestCase
  def test_undefined_method_calls_return_bottom
    assert_bottom bottom.some_random_undefined_method
  end

  def test_equals
    assert bottom == bottom
    assert ! (bottom == Object.new)
  end

  def test_math_operators
    assert_bottom bottom + 1
    assert_bottom bottom - 1
    assert_bottom bottom * 1
    assert_bottom bottom / 1
    assert_bottom bottom ** 1
  end

  def test_math_operators_reversed
    assert_bottom 1 + bottom
    assert_bottom 1 - bottom
    assert_bottom 1 * bottom
    assert_bottom 1 / bottom
    assert_bottom 2 ** bottom
  end

  def test_comparisons
    assert_bottom bottom < 1
    assert_bottom bottom <= 1
    assert_bottom bottom > 1
    assert_bottom bottom >= 1
    assert_bottom bottom <=> 1
  end

  def test_comparisons_reversed
    assert_bottom 1 < bottom
    assert_bottom 1 <= bottom
    assert_bottom 1 > bottom
    assert_bottom 1 >= bottom
    assert_bottom 1 <=> bottom
  end

  def test_base_level_methods
    assert_kind_of FlexMock::Bottom, bottom
  end

  def test_cant_create_a_new_bottom
    assert_raises(NoMethodError) do FlexMock::Bottom.new end
  end

  def test_cant_clone_bottom
    assert_bottom bottom.clone
    assert_equal bottom.__id__, bottom.clone.__id__
  end

  def test_string_representations
    assert_equal "BOTTOM", bottom.to_s
    assert_equal "BOTTOM", bottom.inspect
  end

  def test_bottom_is_not_nil
    assert ! bottom.nil?
  end

  private

  def assert_bottom(obj)
    assert bottom == obj
  end

  def bottom
    FlexMock::BOTTOM
  end
end


class TestBottomMocking < Test::Unit::TestCase
  include FlexMock::TestCase

  def setup
    @mock = flexmock.should_respond_with_bottom
  end

  def test_bottom_mocking
    assert_equal FlexMock::BOTTOM, @mock.some_undefined_method
  end

  def test_bottom_mocking_with_arguments
    assert_equal FlexMock::BOTTOM, @mock.xyzzy(1,:two,"three")
  end

  def test_method_chains_with_bottom_are_bottom_preserving
    assert_equal FlexMock::BOTTOM, @mock.a.b.c.d.e.f(1).g.h.i.j
  end
end

class TestPartiallyMockingBottom < Test::Unit::TestCase
  include FlexMock::TestCase

  def test_bottom_can_be_partially_mocked
  end
end
