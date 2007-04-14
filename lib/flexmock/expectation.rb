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
  # An Expectation is returned from each +should_receive+ message sent
  # to mock object.  Each expectation records how a message matching
  # the message name (argument to +should_receive+) and the argument
  # list (given by +with+) should behave.  Mock expectations can be
  # recorded by chaining the declaration methods defined in this
  # class.
  #
  # For example:
  #
  #   mock.should_receive(:meth).with(args).and_returns(result)
  #
  class Expectation

    attr_reader :expected_args, :order_number
    attr_accessor :mock

    # Create an expectation for a method named +sym+.
    def initialize(mock, sym)
      @mock = mock
      @sym = sym
      @expected_args = nil
      @count_validators = []
      @count_validator_class = ExactCountValidator
      @actual_count = 0
      @return_value = nil
      @return_block = lambda { @return_value }
      @order_number = nil
    end

    def to_s
      FlexMock.format_args(@sym, @expected_args)
    end

    # Verify the current call with the given arguments matches the
    # expectations recorded in this object.
    def verify_call(*args)
      validate_order
      @actual_count += 1
      @return_block.call(*args)
    end

    # Is this expectation eligible to be called again?  It is eligible
    # only if all of its count validators agree that it is eligible.
    def eligible?
      @count_validators.all? { |v| v.eligible?(@actual_count) }
    end

    # Validate that the order
    def validate_order
      return if @order_number.nil?
      FlexMock.check("method #{to_s} called out of order " +
      "(expected order #{@order_number}, was #{@mock.mock_current_order})") {
        @order_number >= @mock.mock_current_order
      }
      @mock.mock_current_order = @order_number
    end
    private :validate_order

    # Validate the correct number of calls have been made.  Called by
    # the teardown process.
    def mock_verify
      @count_validators.each do |v|
        v.validate(@actual_count)
      end
    end

    # Does the argument list match this expectation's argument
    # specification.
    def match_args(args)
      # TODO: Rethink this:
      # return false if @expected_args.nil?
      return true if @expected_args.nil?
      return false if args.size != @expected_args.size
      (0...args.size).all? { |i| match_arg(@expected_args[i], args[i]) }
    end

    # Does the expected argument match the corresponding actual value.
    def match_arg(expected, actual)
      expected === actual ||
      expected == actual ||
      ( Regexp === expected && expected === actual.to_s )
    end

    # Declare that the method should expect the given argument list.
    def with(*args)
      @expected_args = args
      self
    end

    # Declare that the method should be called with no arguments.
    def with_no_args
      with
    end

    # Declare that the method can be called with any number of
    # arguments of any type.
    def with_any_args
      @expected_args = nil
      self
    end

    # :call-seq:
    #   and_return(value)
    #   and_return(value, value, ...)
    #   and_return { |*args| code }
    #
    # Declare that the method returns a particular value (when the
    # argument list is matched).
    #
    # * If a single value is given, it will be returned for all matching
    #   calls.
    # * If multiple values are given, each value will be returned in turn for
    #   each successive call.  If the number of matching calls is greater
    #   than the number of values, the last value will be returned for
    #   the extra matching calls.
    # * If a block is given, it is evaluated on each call and its
    #   value is returned.
    #
    # For example:
    #
    #  mock.should_receive(:f).returns(12)   # returns 12
    #
    #  mock.should_receive(:f).with(String). # returns an
    #    returns { |str| str.upcase }        # upcased string
    #
    # +and_return+ is an alias for +returns+.
    #
    def and_return(*args, &block)
      @return_block = 
        if block_given? 
           block
        else
          lambda { args.size == 1 ? args.first : args.shift }
        end
      self
    end
    alias :returns :and_return  # :nodoc:

    # Declare that the method may be called any number of times.
    def zero_or_more_times
      at_least.never
    end

    # Declare that the method is called +limit+ times with the
    # declared argument list.  This may be modified by the +at_least+
    # and +at_most+ declarators.
    def times(limit)
      @count_validators << @count_validator_class.new(self, limit) unless limit.nil?
      @count_validator_class = ExactCountValidator
      self
    end

    # Declare that the method is never expected to be called with the
    # given argument list.  This may be modified by the +at_least+ and
    # +at_most+ declarators.
    def never
      times(0)
    end

    # Declare that the method is expected to be called exactly once
    # with the given argument list.  This may be modified by the
    # +at_least+ and +at_most+ declarators.
    def once
      times(1)
    end

    # Declare that the method is expected to be called exactly twice
    # with the given argument list.  This may be modified by the
    # +at_least+ and +at_most+ declarators.
    def twice
      times(2)
    end

    # Modifies the next call count declarator (+times+, +never+,
    # +once+ or +twice+) so that the declarator means the method is
    # called at least that many times.
    #
    # E.g. method f must be called at least twice:
    #
    #   mock.should_receive(:f).at_least.twice
    #
    def at_least
      @count_validator_class = AtLeastCountValidator
      self
    end

    # Modifies the next call count declarator (+times+, +never+,
    # +once+ or +twice+) so that the declarator means the method is
    # called at most that many times.
    #
    # E.g. method f must be called no more than twice
    #
    #   mock.should_receive(:f).at_most.twice
    #
    def at_most
      @count_validator_class = AtMostCountValidator
      self
    end

    # Declare that the given method must be called in order.  All
    # ordered method calls must be received in the order specified by
    # the ordering of the +should_receive+ messages.  Receiving a
    # methods out of the specified order will cause a test failure.
    #
    # If the user needs more fine control over ordering
    # (e.g. specifying that a group of messages may be received in any
    # order as long as they all come after another group of messages),
    # a _group_ _name_ may be specified in the +ordered+ calls.  All
    # messages within the same group may be received in any order.
    #
    # For example, in the following, messages +flip+ and +flop+ may be
    # received in any order (because they are in the same group), but
    # must occur strictly after +start+ but before +end+.  The message
    # +any_time+ may be received at any time because it is not
    # ordered.
    #
    #    m = FlexMock.new
    #    m.should_receive(:any_time)
    #    m.should_receive(:start).ordered
    #    m.should_receive(:flip).ordered(:flip_flop_group)
    #    m.should_receive(:flop).ordered(:flip_flop_group)
    #    m.should_receive(:end).ordered
    #
    def ordered(group_name=nil)
      if group_name.nil?
        @order_number = @mock.mock_allocate_order
      elsif (num = @mock.mock_groups[group_name])
        @order_number = num
      else
        @order_number = @mock.mock_allocate_order
        @mock.mock_groups[group_name] = @order_number
      end
      self
    end
  end

  ##########################################################################
  # A composite expectation allows several expectations to be grouped into a
  # single composite and then apply the same constraints to  all expectations
  # in the group.
  class CompositeExpectation

    # Initialize the composite expectation.
    def initialize
      @expectations = []
    end

    # Add an expectation to the composite.
    def add(expectation)
      @expectations << expectation
    end

    # Apply the constraint method to all expectations in the composite.
    def method_missing(sym, *args, &block)
      @expectations.each do |expectation|
        expectation.send(sym, *args, &block)
      end
      self
    end

    # The following methods return a value, so we make an arbitrary choice
    # and return the value for the first expectation in the composite.
    
    # Return the order number of the first expectation in the list.
    def order_number
      @expectations.first.order_number
    end

    # Return the associated mock object.
    def mock
      @expectations.first.mock
    end
    
    # Start a new method expectation.  The following constraints will be
    # applied to the new expectation.
    def should_receive(*args, &block)
      @expectations.first.mock.should_receive(*args, &block)
    end

    # Return a string representations
    def to_s
      if @expectations.size > 1
        "[" + @expectations.collect { |e| e.to_s }.join(', ') + "]"
      else
        @expectations.first.to_s
      end
    end
  end

  ##########################################################################
  # An expectation recorder records any expectations received and plays them
  # back on demand.  This is used to collect the expectations in the blockless
  # version of the new_instances call.
  #
  class ExpectationRecorder

    # Initialize the recorder.
    def initialize
      @expectations = []
    end

    # Save any incoming messages to be played back later.
    def method_missing(sym, *args, &block)
      @expectations << [sym, args, block]
      self
    end
    
    # Apply the recorded messages to the given object in a chaining fashion
    # (i.e. the result of the previous call is used as the target of the next
    # call).
    def apply(mock)
      obj = mock
      @expectations.each do |sym, args, block|
        obj = obj.send(sym, *args, &block)
      end
    end
  end
end
