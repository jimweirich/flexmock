require 'flexmock/spy_describers'

class FlexMock
  module TestUnitAssertions
    include FlexMock::SpyDescribers

    def assert_spy_called(spy, method_name, *args)
      _assert_spy_called(false, spy, method_name, *args)
    end

    def assert_spy_not_called(spy, method_name, *args)
      _assert_spy_called(true, spy, method_name, *args)
    end

    private

    def _assert_spy_called(negative, spy, method_name, *args)
      options = {}
      if method_name.is_a?(Hash)
        options = method_name
        method_name = args.shift
      end
      args = nil if args == [:_]
      bool = spy.flexmock_received?(method_name, args, options)
      if negative
        bool = !bool
        message = describe_spy_negative_expectation(spy, method_name, args, options)
      else
        message = describe_spy_expectation(spy, method_name, args, options)
      end
      assert bool, message
    end
  end
end
