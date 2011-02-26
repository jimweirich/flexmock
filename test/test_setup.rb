require 'test/unit'
require 'fileutils'

require 'flexmock'
require 'test/redirect_error'

class FlexMock
  module TestCase
    def assertion_failed_error
      FlexMock.framework_adapter.assertion_failed_error
    end

    # Assertion helper used to assert validation failure.  If a
    # message is given, then the error message should match the
    # expected error message.
    def assert_failure(message=nil)
      ex = assert_raises(assertion_failed_error) { yield }
      if message
        case message
        when Regexp
          assert_match message, ex.message
        when String
          assert ex.message.index(message), "Error message '#{ex.message}' should contain '#{message}'"
        end
      end
      ex
    end

  end
end
