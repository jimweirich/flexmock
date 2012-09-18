#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'
require 'flexmock/spy_describers'

class FlexMock

  ####################################################################
  # Base class for all the count validators.
  #
  class CountValidator
    include FlexMock::SpyDescribers

    def initialize(expectation, limit)
      @exp = expectation
      @limit = limit
    end

    # If the expectation has been called +n+ times, is it still
    # eligible to be called again?  The default answer compares n to
    # the established limit.
    def eligible?(n)
      n < @limit
    end

    def calls(n)
      n == 1 ? "call" : "calls"
    end
  end

  ####################################################################
  # Validator for exact call counts.
  #
  class ExactCountValidator < CountValidator
    # Validate that the method expectation was called exactly +n+
    # times.
    def validate(n)
      @exp.flexmock_location_filter do
        FlexMock.framework_adapter.assert_block(
          lambda {
            "Method '#{@exp}' called incorrect number of times\n" +
            "#{@limit} #{calls(@limit)} expected\n" +
            "#{n} matching #{calls(n)} found\n" +
            describe_calls(@exp.mock)
          }
          ) { @limit == n }
      end
    end
  end

  ####################################################################
  # Validator for call counts greater than or equal to a limit.
  #
  class AtLeastCountValidator < CountValidator
    # Validate the method expectation was called no more than +n+
    # times.
    def validate(n)
      @exp.flexmock_location_filter do
        FlexMock.framework_adapter.assert_block(
          lambda {
            "Method '#{@exp}' called incorrect number of times\n" +
            "At least #{@limit} #{calls(@limit)} expected\n" +
            "#{n} matching #{calls(n)} found\n" +
            describe_calls(@exp.mock)
          }) { n >= @limit }
      end
    end

    # If the expectation has been called +n+ times, is it still
    # eligible to be called again?  Since this validator only
    # establishes a lower limit, not an upper limit, then the answer
    # is always true.
    def eligible?(n)
      true
    end
  end

  ####################################################################
  # Validator for call counts less than or equal to a limit.
  #
  class AtMostCountValidator < CountValidator
    # Validate the method expectation was called at least +n+ times.
    def validate(n)
      @exp.flexmock_location_filter do
        FlexMock.framework_adapter.assert_block(
          lambda {
            "Method '#{@exp}' called incorrect number of times\n" +
            "At most #{@limit} #{calls(@limit)} expected\n" +
            "#{n} matching #{calls(n)} found\n" +
            describe_calls(@exp.mock)
          }) { n <= @limit }
      end
    end
  end
end
