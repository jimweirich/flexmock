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

# Sample FlexMock Usage.

class TestSamples < Test::Unit::TestCase
  include FlexMock::TestCase

  # This is a basic example where we setup a mock object to mimic an
  # IO object.  We know that the +count_lines+ method uses gets, so we
  # tell the mock object to handle +gets+ by returning successive
  # elements of an array (just as the real +gets+ returns successive
  # elements of a file.
  def test_file_io
    mock_file = flexmock("file")
    mock_file.should_receive(:gets).and_return("line 1", "line 2", nil)
    assert_equal 2, count_lines(mock_file)
  end

  # Count the number of lines in a file.  Used in the test_file_io
  # test.
  def count_lines(file)
    n = 0
    while file.gets
      n += 1
    end
    n
  end
end

