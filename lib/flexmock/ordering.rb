#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

class FlexMock

  # #################################################################
  # The ordering module contains the methods and data structures used
  # to determine proper orderring of mocked calls.  By providing the
  # functionality in a module, a individual mock object can order its
  # own calls, and the container can provide ordering at a global
  # level.
  module Ordering

    # Allocate the next available order number.
    def mock_allocate_order
      @mock_allocated_order ||= 0
      @mock_allocated_order += 1
    end

    # Hash of groups defined in this ordering.
    def mock_groups
      @mock_groups ||= {}
    end

    # Current order number in this ordering.
    def mock_current_order
      @mock_current_order ||= 0
    end

    # Set the current order for this ordering.
    def mock_current_order=(value)
      @mock_current_order = value
    end

    def mock_validate_order(method_name, order_number)
      FlexMock.check("method #{method_name} called out of order " +
        "(expected order #{order_number}, was #{mock_current_order})") {
        order_number >= self.mock_current_order
      }
      self.mock_current_order = order_number
    end
  end
end
