#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

class FlexMock
  module GenericTestCase
    def self.define_extensions_on(klass)
      klass.class_eval do
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

if defined?(MiniTest)
  module MiniTest
    class Unit
      class TestCase
        FlexMock::GenericTestCase.define_extensions_on(self)
      end
    end
  end
else
  module Test
    module Unit
      class TestCase
        FlexMock::GenericTestCase.define_extensions_on(self)
      end
    end
  end
end
