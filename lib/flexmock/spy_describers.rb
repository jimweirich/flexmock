class FlexMock

    module SpyDescribers
      def describe_spy_expectation(spy, sym, args, options={})
        describe(spy, sym, args, options)
      end

      def describe_spy_negative_expectation(spy, sym, args, options={})
        describe(spy, sym, args, options, " NOT")
      end

      private

      def describe(spy, sym, args, options, not_clause="")
        result = "expected "
        result << call_description(sym, args, options[:any_args])
        result << " to#{not_clause} be called on "
        result << spy.inspect
        result << times_description(options[:times])
        result << block_description(options[:with_block])
        result << "."
        result
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

      def call_description(sym, args, any_args)
        if any_args || args.nil?
          "#{sym}(...)"
        else
          "#{sym}(#{args.map { |o| o.inspect }.join(', ')})"
        end
      end
    end

end
