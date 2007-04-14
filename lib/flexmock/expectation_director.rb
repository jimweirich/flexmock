#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'

class FlexMock

  ####################################################################
  # The expectation director is responsible for routing calls to the
  # correct expectations for a given argument list.
  #
  class ExpectationDirector

    # Create an ExpectationDirector for a mock object.
    def initialize(sym)
      @sym = sym
      @expectations = []
      @expected_order = nil
    end

    # Invoke the expectations for a given set of arguments.
    #
    # First, look for an expectation that matches the arguements and
    # is eligible to be called.  Failing that, look for a expectation
    # that matches the arguments (at this point it will be ineligible,
    # but at least we will get a good failure message).  Finally,
    # check for expectations that don't have any argument matching
    # criteria.
    def call(*args)
      exp = @expectations.find { |e| e.match_args(args) && e.eligible? } ||
      @expectations.find { |e| e.match_args(args) }
      FlexMock.check("no matching handler found for " +
      FlexMock.format_args(@sym, args)) { ! exp.nil? }
      exp.verify_call(*args)
    end

    # Append an expectation to this director.
    def <<(expectation)
      @expectations << expectation
    end

    # Do the post test verification for this directory.  Check all the
    # expectations.
    def mock_verify
      @expectations.each do |exp|
        exp.mock_verify
      end
    end
  end

end
