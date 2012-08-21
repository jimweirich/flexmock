require 'flexmock/spy_describers'

class FlexMock
  module RSpecMatchers

    class HaveReceived
      include SpyDescribers

      def initialize(sym, args, block)
        @sym = sym
        @args = args
        @block = block
        @times = nil
        @needs_block = nil
      end

      def matches?(spy)
        @spy = spy
        @options = {}
        @options[:times] = @times if @times
        @options[:with_block] = @needs_block unless @needs_block.nil?
        @options[:any_args] = @any_args unless @any_args.nil?
        @spy.flexmock_was_called_with?(@sym, @args, @options)
      end

      def failure_message_for_should
        describe_spy_expectation(@spy, @sym, @args, @options)
      end

      def failure_message_for_should_not
        describe_spy_negative_expectation(@spy, @sym, @args, @options)
      end

      def with_a_block
        @needs_block = true
        self
      end

      def without_a_block
        @needs_block = false
        self
      end

      def times(n)
        @times = n
        self
      end

      def never
        times(0)
      end

      def once
        times(1)
      end

      def twice
        times(2)
      end

      def with_any_args
        @any_args = true
        self
      end
    end

    class HaveReceivedCatcher
      def method_missing(sym, *args, &block)
        HaveReceived.new(sym, args, block)
      end
    end

    def have_received
      HaveReceivedCatcher.new
    end
  end
end

RSpec::configure do |config|
  config.include(FlexMock::RSpecMatchers)
end
