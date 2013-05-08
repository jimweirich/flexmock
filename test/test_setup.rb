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
    def assert_failure(options={}, &block)
      message = options[:message]
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

    # Similar to assert_failure, but assumes that a mock generated
    # error object is return, so additional tests on the backtrace are
    # added.
    def assert_mock_failure(options={}, &block)
      ex = assert_failure(options, &block)
      file = eval("__FILE__", block.binding)
      assert_matching_line(ex, file, options)
    end

    # Assert that there is a line matching file in the backtrace.
    # Options are:
    #
    #     deep: true -- matching line can be anywhere in backtrace,
    #                   otherwise it must be the first.
    #
    #     line: n    -- Add a line number to the match
    #
    def assert_matching_line(ex, file, options)
      line = options[:line]
      search_all = options[:deep]
      if line
        loc_re = /#{Regexp.quote(file)}:#{line}/
      else
        loc_re = Regexp.compile(Regexp.quote(file))
      end


      if search_all
        bts = ex.backtrace.join("\n")
        assert_with_block("expected a backtrace line to match #{loc_re}\nBACKTRACE:\n#{bts}") {
          ex.backtrace.any? { |bt| loc_re =~ bt }
        }
      else
        assert_match(loc_re, ex.backtrace.first)
      end

      ex
    end

    unless defined?(refute_match)
      def refute_match(*args)
        assert_no_match(*args)
      end
    end

    def assert_with_block(msg=nil)
      unless yield
        assert(false, msg || "Expected block to yield true")
      end
    end

    def pending(msg="")
      state = "PASSING"
      begin
        yield
      rescue Exception => _
        state = "FAILING"
      end
      where = caller.first.split(/:in/).first
      puts "\n#{state} PENDING TEST (#{msg}) #{where}"
    end
  end
end
