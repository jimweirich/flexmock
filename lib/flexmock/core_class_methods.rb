#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'
require 'flexmock/mock_container'

class FlexMock
  class << self
    attr_reader :framework_adapter

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
      container = UseContainer.new
      mocks = names.collect { |n| container.flexmock(n) }
      yield(*mocks)
    rescue Exception => _
      container.got_exception = true
      raise
    ensure
      container.flexmock_teardown
    end

    # Class method to format a method name and argument list as a nice
    # looking string.
    def format_call(sym, args)  # :nodoc:
      "#{sym}(#{format_args(args)})"
    end

    # Class method to format a list of args (the part between the
    # parenthesis).
    def format_args(args)
      if args
        args.collect { |a| a.inspect }.join(', ')
      else
        "*args"
      end
    end

    # Check will assert the block returns true.  If it doesn't, an
    # assertion failure is triggered with the given message.
    def check(msg, &block)  # :nodoc:
      FlexMock.framework_adapter.make_assertion(msg, &block)
    end

  end

  # Container object to be used by the FlexMock.use method.
  class UseContainer
    include MockContainer

    attr_accessor :got_exception

    def initialize
      @got_exception = false
    end

    def passed?
      ! got_exception
    end
  end
end
