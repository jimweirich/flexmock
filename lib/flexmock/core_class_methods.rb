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
  class << self
    attr_reader :framework_adapter

    # :call-seq:
    #   should_receive(args) { |symbol| ... }
    #
    # This method provides common handling for the various should_receive
    # argument lists. It sorts out the differences between symbols, arrays and
    # hashes, and identifies the method names specified by each.  As each
    # method name is identified, create a mock expectation for it using the
    # supplied block.
    def should_receive(args)  # :nodoc:
      result = CompositeExpectation.new
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k,v|
            result.add(yield(k.to_sym).and_return(v))
          end
        when Symbol, String
          result.add(yield(arg.to_sym))
        end
      end
      result
    end
    
    # Class method to make sure that verify is called at the end of a
    # test.  One mock object will be created for each name given to
    # the use method.  The mocks will be passed to the block as
    # arguments.  If no names are given, then a single anonymous mock
    # object will be created.
    #
    # At the end of the use block, each mock object will be verified
    # to make sure the proper number of calls have been made.
    #
    # Usage:
    #
    #   FlexMock.use("name") do |mock|    # Creates a mock named "name"
    #     mock.should_receive(:meth).
    #       returns(0).once
    #   end                               # mock is verified here
    #
    # NOTE: If you include FlexMock::TestCase into your test case
    # file, you can create mocks that will be automatically verified in
    # the test teardown by using the +flexmock+ method.
    #
    def use(*names)
      names = ["unknown"] if names.empty?
      got_excecption = false
      mocks = names.collect { |n| new(n) }
      yield(*mocks)
    rescue Exception => ex
      got_exception = true
      raise
    ensure
      mocks.each do |mock|
        mock.mock_verify     unless got_exception
      end
    end

    # Class method to format a method name and argument list as a nice
    # looking string.
    def format_args(sym, args)  # :nodoc:
      if args
        "#{sym}(#{args.collect { |a| a.inspect }.join(', ')})"
      else
        "#{sym}(*args)"
      end
    end

    # Check will assert the block returns true.  If it doesn't, an
    # assertion failure is triggered with the given message.
    def check(msg, &block)  # :nodoc:
      FlexMock.framework_adapter.assert_block(msg, &block)
    end
  end

end