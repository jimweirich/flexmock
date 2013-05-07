#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/test_unit_integration'

if defined?(MiniTest)
  module MiniTest
    class Unit
      class TestCase
        include FlexMock::ArgumentTypes
        include FlexMock::MockContainer

        # Alias the original teardown behavior for later use.
        alias :flexmock_original_teardown :teardown

        # Teardown the test case, verifying any mocks that might have been
        # defined in this test case.
        def teardown
          flexmock_teardown
          flexmock_original_teardown
        end
      end
    end
  end
else
  module Test
    module Unit
      class TestCase
        include FlexMock::ArgumentTypes
        include FlexMock::MockContainer

        # Alias the original teardown behavior for later use.
        alias :flexmock_original_teardown :teardown

        # Teardown the test case, verifying any mocks that might have been
        # defined in this test case.
        def teardown
          flexmock_teardown
          flexmock_original_teardown
        end

      end
    end
  end
end
