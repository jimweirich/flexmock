#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'
require 'flexmock/argument_types'
require 'flexmock/ordering'
require 'flexmock/mock_builder'

class FlexMock


  # Mock container methods
  #
  # Include this module in to get integration with FlexMock.  When this module
  # is included, mocks may be created with a simple call to the +flexmock+
  # method.  Mocks created with via the method call will automatically be
  # verified in the teardown of the test case.
  #
  module MockContainer
    include Ordering

    # Do the flexmock specific teardown stuff.  If you need finer control,
    # you can use either +flexmock_verify+ or +flexmock_close+.
    def flexmock_teardown
      flexmock_verify unless flexmock_test_has_failed?
    ensure
      flexmock_close
    end

    # Perform verification on all mocks in the container.
    def flexmock_verify
      flexmock_created_mocks.each do |m|
        m.flexmock_verify
      end
    end

    # List of mocks created in this container
    def flexmock_created_mocks
      @flexmock_created_mocks ||= []
    end

    # Close all the mock objects in the container.  Closing a mock object
    # restores any original behavior that was displaced by the mock.
    def flexmock_close
      flexmock_created_mocks.each do |m|
        m.flexmock_teardown
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
    def flexmock(*args, &block)
      location = caller.first
      @flexmock_worker ||= MockBuilder.new(self)
      @flexmock_worker.define_a_mock(location, *args, &block)
    end
    alias flexstub flexmock

    # Remember the mock object / stub in the mock container.
    def flexmock_remember(mocking_object)
      @flexmock_created_mocks ||= []
      @flexmock_created_mocks << mocking_object
      mocking_object.flexmock_container = self
      mocking_object
    end

    private

    # In frameworks (e.g. MiniTest) passed? will return nil to
    # indicate the test isn't over yet.  From our point of view we are
    # only interested if the test has actually failed, so we wrap the
    # raw call to passed? and handle accordingly.
    def flexmock_test_has_failed? # :nodoc:
      passed? == false
    end
  end

  class ExtensionRegistry
    def add_extension(extension)
      extensions << extension
    end
    def extensions
      @extensions ||= []
    end
  end

  CONTAINER_HELPER = ExtensionRegistry.new
end
