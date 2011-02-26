require 'test/unit'
require 'flexmock'


class FlexMock
  module TestCase
    def assertion_failed_error
      FlexMock.framework_adapter.assertion_failed_error
    end
  end
end
