class FlexMock

    module SpyDescribers
      def spy_description(spy, sym, args, options)
        result = "have received "
        result << call_description(sym, args)
        result << times_description(options[:times])
        result << block_description(options[:with_block])
        result
      end

      def describe_spy_expectation(spy, sym, args, options={})
        describe_spy(spy, sym, args, options)
      end

      def describe_spy_negative_expectation(spy, sym, args, options={})
        describe_spy(spy, sym, args, options, " NOT")
      end

      private

      def describe_spy(spy, sym, args, options, not_clause="")
        result = "expected "
        result << call_description(sym, args)
        result << " to#{not_clause} be received by " << spy.inspect
        result << times_description(options[:times])
        result << block_description(options[:with_block])
        result << ".\n"
        result << describe_calls(spy)
        result
      end

      def describe_calls(spy)
        result = ''
        if spy.flexmock_calls.empty?
          result << "No messages have been received\n"
        else
          result << "The following messages have been received:\n"
          spy.flexmock_calls.each do |call_record|
            append_call_record(result, call_record)
          end
        end
        result
      end

      def append_call_record(result, call_record)
        result <<
          "    " <<
          call_description(call_record.method_name, call_record.args)
        if call_record.expectation
          result <<
            " matched by " <<
            call_record.expectation.description
        end
        result << "\n"
      end

      def times_description(times)
        case times
        when 0
          " never"
        when 1
          " once"
        when 2
          " twice"
        when nil
          ""
        else
          " #{times} times"
        end
      end

      def block_description(needs_block)
        case needs_block
        when true
          " with a block"
        when false
          " without a block"
        else
          ""
        end
      end

      def call_description(sym, args)
        if args
          "#{sym}(#{args.map { |o| o.inspect }.join(', ')})"
        else
          "#{sym}(...)"
        end
      end
    end

end
