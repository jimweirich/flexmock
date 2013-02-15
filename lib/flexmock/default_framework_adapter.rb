#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'

class FlexMock
  class DefaultFrameworkAdapter
    def make_assertion(msg, &block)
      unless yield
        msg = msg.call if msg.is_a?(Proc)
        fail assertion_failed_error, msg
      end
    end

    def assert_equal(a, b, msg=nil)
      make_assertion(msg || "Expected equal") { a == b }
    end

    class AssertionFailedError < StandardError; end
    def assertion_failed_error
      AssertionFailedError
    end
  end
end
