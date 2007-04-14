#!/usr/bin/env ruby

#---
# Copyright 2006 by Jim Weirich (jweirich@one.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/unit'

# Sample FlexMock Usage.

class TestSamples < Test::Unit::TestCase

  # This is a basic example where we setup a mock object to mimic an
  # IO object.  We know that the +count_lines+ method uses gets, so we
  # tell the mock object to handle +gets+ by returning successive
  # elements of an array (just as the real +gets+ returns successive
  # elements of a file.
  def test_file_io
    file = FlexMock.new
    filedata = ["line 1", "line 2"]
    file.mock_handle(:gets) { filedata.shift }
    assert_equal 2, count_lines(file)
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

  def test_x
  end
end

