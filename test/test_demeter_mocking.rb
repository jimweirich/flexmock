#!/usr/bin/env ruby

class TestDemeterMocking < Test::Unit::TestCase
  include FlexMock::TestCase

  def test_x;  end
  def xtest_demeter_mocking
    m = flexmock("A")
    m.should_receive("children.first").and_return(flexmock(:first))
    assert_equal :first, m.children.first
  end

end
