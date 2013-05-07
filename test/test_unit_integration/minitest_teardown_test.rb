require "minitest/autorun"
require 'flexmock/test_unit'

class SimpleTest < MiniTest::Unit::TestCase

  # This validates that the minitest teardown method is properly
  # aliased when using MiniTest.
  #
  # (see https://github.com/jimweirich/flexmock/issues/14).
  #
  def test_flexmock
    flexmock()
  end
end
