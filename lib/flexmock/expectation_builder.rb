#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/composite_expectation'

class FlexMock

  class ExpectationBuilder
    # :call-seq:
    #   parse_should_args(args) { |symbol| ... }
    #
    # This method provides common handling for the various should_receive
    # argument lists. It sorts out the differences between symbols, arrays and
    # hashes, and identifies the method names specified by each.  As each
    # method name is identified, create a mock expectation for it using the
    # supplied block.
    def parse_should_args(mock, args, &block)  # :nodoc:
      result = CompositeExpectation.new
      args.each do |arg|
        case arg
        when Hash
          arg.each do |k,v|
            exp = create_expectation(mock, k, &block).and_return(v)
            result.add(exp)
          end
        when Symbol, String
          result.add(create_expectation(mock, arg, &block))
        end
      end
      result
    end

    # Create an expectation for the name on this mock. For simple
    # mocks, this is done by calling the provided block parameter and
    # letting the calling site handle the creation of the expectation
    # (which differs between full mocks and partial mocks).
    #
    # If the name_chain contains demeter mocking chains, then the
    # process is more complex. A series of mocks are created, each
    # component of the chain returning the next mock until the
    # expectation for the last component is returned.
    def create_expectation(mock, name_chain, &block)
      names = name_chain.to_s.split('.').map { |n| n.to_sym }
      check_method_names(names)
      if names.size == 1
        block.call(names.first)
      elsif names.size > 1
        create_demeter_chain(mock, names)
      else
        fail "Empty list of names"
      end
    end

    # Build the chain of mocks for demeter style mocking.
    #
    # This method builds a chain of mocks to support demeter style
    # mocking.  Given a mock chain of "first.second.third.last", we
    # must build a chain of mock methods that return the next mock in
    # the chain.  The expectation for the last method of the chain is
    # returned as the result of the method.
    #
    # Things to consider:
    #
    # * The expectations for all methods but the last in the chain
    #   will be setup to expect no parameters and to return the next
    #   mock in the chain.
    #
    # * It could very well be the case that several demeter chains
    #   will be defined on a single mock object, and those chains
    #   could share some of the same methods (e.g. "mock.one.two.read"
    #   and "mock.one.two.write" both share the methods "one" and
    #   "two"). It is important that the shared methods return the
    #   same mocks in both chains.
    #
    def create_demeter_chain(mock, names)
      container = mock.flexmock_container
      last_method = names.pop
      names.each do |name|
        exp = mock.flexmock_find_expectation(name)
        if exp
          next_mock = exp._return_value([])
          check_proper_mock(next_mock, name)
        else
          next_mock = container.flexmock("demeter_#{name}")
          mock.should_receive(name).and_return(next_mock)
        end
        mock = next_mock
      end
      mock.should_receive(last_method)
    end

    # Check that the given mock is a real FlexMock mock.
    def check_proper_mock(mock, method_name)
      unless mock.respond_to?(:should_receive)
        fail FlexMock::UsageError,
          "Conflicting mock declaration for '#{method_name}' in demeter style mock"
      end
    end

    METHOD_NAME_ALTS = [
      '[A-Za-z_][A-Za-z0-9_]*[=!?]?',
      '\[\]=?',
      '\*\\*',
      '<<',
      '>>',
      '<=>',
      '[<>=!]=',
      '[=!]~',
      '===',
      '[-+]@',
      '[-+\*\/%&^|<>~`!]'
    ].join("|")
    METHOD_NAME_RE = /^(#{METHOD_NAME_ALTS})$/

    # Check that all the names in the list are valid method names.
    def check_method_names(names)
      names.each do |name|
        fail FlexMock::UsageError, "Ill-formed method name '#{name}'" if
          name.to_s !~ METHOD_NAME_RE
      end
    end
  end

  EXP_BUILDER = ExpectationBuilder.new
end
