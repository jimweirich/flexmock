require 'flexmock/spy_describers'

class FlexMock
  module TestUnitAssertions
    include FlexMock::SpyDescribers

    def assert_spy_called(spy, method_name, *args)
      options = {}
      if method_name.is_a?(Hash)
        options = method_name
        method_name = args.shift
      end
      assert(spy.flexmock_was_called_with?(method_name, args, options),
        describe_spy_expectation(spy, method_name, args, options))
    end
  end
end
