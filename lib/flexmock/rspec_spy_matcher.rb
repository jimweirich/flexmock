
class FlexMock
  module RSpecMatchers

    class HaveReceived
      def initialize(sym, args, block)
        @sym = sym
        @args = args
        @block = block
        @times = nil
        @need_block = nil
      end

      def matches?(spy)
        @spy = spy
        options = {}
        options[:times] = @times if @times
        options[:with_block] = @needs_block unless @needs_block.nil?
        @spy.flexmock_was_called_with?(@sym, @args, options)
      end

      def failure_message_for_should
        "expected #{call_description(@sym, @args)} to be called on #{@spy.inspect}#{times_description}#{block_description}."
      end

      def failure_message_for_should_not
        "expected #{call_description(@sym, @args)} to not be called on #{@spy.inspect}#{times_description}#{block_description}."
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

      private

      def times_description
        case @times
        when 0
          " never"
        when 1
          " once"
        when 2
          " twice"
        else
          ""
        end
      end

      def block_description
        case @needs_block
        when true
          " with a block"
        when false
          " without a block"
        else
          ""
        end
      end

      def call_description(sym, args)
        "#{sym}(#{args.map { |o| o.inspect }.join(', ')})"
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
