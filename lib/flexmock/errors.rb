#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'

class FlexMock

  # Error raised when flexmock is used incorrectly.
  class UsageError < ::RuntimeError
  end

  class MockError < ::RuntimeError
  end

end
