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
  
  # ######################################################################
  # Mock container methods
  #
  # Include this module in to get integration with FlexMock.  When this module
  # is included, mocks may be created with a simple call to the +flexmock+
  # method.  Mocks created with via the method call will automatically be
  # verified in the teardown of the test case.
  #   
  module MockContainer
    # Do the flexmock specific teardown stuff.  If you need finer control,
    # you can use either +flexmock_verify+ or +flexmock_close+.
    def flexmock_teardown
      flexmock_verify if passed?
    ensure
      flexmock_close
    end

    # Perform verification on all mocks in the container.
    def flexmock_verify
      @flexmock_created_mocks ||= []
      @flexmock_created_mocks.each do |m|
        m.mock_verify
      end
    end
    
    # Close all the mock objects in the container.  Closing a mock object
    # restores any original behavior that was displaced by the mock.
    def flexmock_close
      @flexmock_created_mocks ||= []
      @flexmock_created_mocks.each do |m|
        m.mock_teardown
      end
      @flexmock_created_mocks = []
    end
    
    # Create a mocking object in the FlexMock framework.  The +flexmock+
    # method has a number of options available, depending on just what kind of
    # mocking object your require.  Mocks created via +flexmock+ will be
    # automatically verify during the teardown phase of your test framework.
    #
    # :call-seq:
    #   flexmock() { |mock| ... }
    #   flexmock(name) { |mock| ... }
    #   flexmock(expect_hash) { |mock| ... }
    #   flexmock(name, expect_hash) { |mock| ... }
    #   flexmock(real_object) { |mock| ... }
    #   flexmock(real_object, name) { |mock| ... }
    #   flexmock(real_object, name, expect_hash) { |mock| ... }
    #   flexmock(:base, string, name, expect_hash) { |mock| ... }
    #
    # <b>Note:</b> A plain flexmock() call without a block will return the
    # mock object (the object that interprets <tt>should_receive</tt> and its
    # brethern). A flexmock() call that _includes_ a block will return the
    # domain objects (the object that will interpret domain messages) since
    # the mock will be passed to the block for configuration. With regular
    # mocks, this distinction is unimportant because the mock object and the
    # domain object are the same object.  However, with partial mocks, the
    # mock object is separation from the domain object.  Keep that distinciton
    # in mind.
    #
    # name ::
    #   Name of the mock object.  If no name is given, "unknown" is used for
    #   full mocks and "flexmock(<em>real_object</em>)" is used for partial
    #   mocks.
    #
    # expect_hash ::
    #   Hash table of method names and values.  Each method/value pair is 
    #   used to setup a simple expectation so that if the mock object
    #   receives a message matching an entry in the table, it returns 
    #   the associated value.  No argument our call count constraints are
    #   added.  Using an expect_hash is identical to calling:
    #
    #       mock.should_receive(method_name).and_return(value)
    #
    #   for each of the method/value pairs in the hash.
    #
    # real_object ::
    #   If a real object is given, then a partial mock is constructed 
    #   using the real_object as a base. Partial mocks (formally referred 
    #   to as stubs) behave as a mock object when an expectation is matched, 
    #   and otherwise will behave like the original object.  This is useful 
    #   when you want to use a real object for testing, but need to mock out 
    #   just one or two methods.  
    #
    # :base ::
    #   Forces the following argument to be used as the base of a
    #   partial mock object.  This explicit tag is only needed if you 
    #   want to use a string or a symbol as the mock base (string and
    #   symbols would normally be interpretted as the mock name).
    #       
    # &block ::
    #   If a block is given, then the mock object is passed to the block and
    #   expectations may be configured within the block.  When a block is given
    #   for a partial mock, flexmock will return the domain object rather than 
    #   the mock object.  
    #
    def flexmock(*args)
      name = nil
      quick_defs = {}
      domain_obj = nil
      safe_mode = false
      while ! args.empty?
        case args.first
        when :base, :safe
          safe_mode = (args.shift == :safe)
          domain_obj = args.shift
        when String, Symbol
          name = args.shift.to_s
        when Hash
          quick_defs = args.shift
        else
          domain_obj = args.shift
        end
      end
      raise UsageError, "a block is required in safe mode" if safe_mode && ! block_given?

      if domain_obj
        mock = flexmock_make_partial_proxy(domain_obj, name, safe_mode)
      else
        mock = FlexMock.new(name || "unknown")
        domain_obj = mock
      end
      flexmock_quick_define(mock, quick_defs)
      yield(mock) if block_given?
      flexmock_remember(mock)
      block_given? ? domain_obj : mock
      domain_obj
    end
    alias flexstub flexmock
    
    private
    
    # Create a PartialMockProxy for the given object.  Use +name+ as
    # the name of the mock object.
    def flexmock_make_partial_proxy(obj, name, safe_mode)
      name ||= "flexmock(#{obj.class.to_s})"
      obj.instance_eval {
        @flexmock_proxy ||= PartialMockProxy.new(obj, FlexMock.new(name), safe_mode)
      }
      obj.instance_variable_get("@flexmock_proxy")
    end

    # Create a set of mocked methods from a hash.
    def flexmock_quick_define(mock, defs)
      defs.each do |method, value|
        mock.should_receive(method).and_return(value)
      end
      mock
    end
    
    # Remember the mock object / stub in the mock container.
    def flexmock_remember(mocking_object)
      @flexmock_created_mocks ||= []
      @flexmock_created_mocks << mocking_object
      mocking_object.mock_container = self
      mocking_object
    end
  end

end
