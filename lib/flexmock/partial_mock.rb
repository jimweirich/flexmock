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
  # PartialMock is used to mate the mock framework to an existing
  # object.  The object is "enhanced" with a reference to a mock
  # object (stored in <tt>@flexmock_mock</tt>).  When the
  # +should_receive+ method is sent to the proxy, it overrides the
  # existing object's method by creating  singleton method that
  # forwards to the mock.  When testing is complete, PartialMock
  # will erase the mocking infrastructure from the object being
  # mocked (e.g. remove instance variables and mock singleton
  # methods).
  #
  class PartialMock
    attr_reader :mock

    # Initialize a PartialMock object.
    def initialize(obj, mock)
      @obj = obj
      @mock = mock
      @method_definitions = {}
      @methods_proxied = []
    end

    # :call-seq:
    #    should_receive(:method_name)
    #    should_receive(:method1, method2, ...)
    #    should_receive(:meth1 => result1, :meth2 => result2, ...)
    #
    # Declare that the partial mock should receive a message with the given
    # name.
    #
    # If more than one method name is given, then the mock object should
    # expect to receive all the listed melthods.  If a hash of method
    # name/value pairs is given, then the each method will return the
    # associated result.  Any expectations applied to the result of
    # +should_receive+ will be applied to all the methods defined in the
    # argument list.
    #
    # An expectation object for the method name is returned as the result of
    # this method.  Further expectation constraints can be added by chaining
    # to the result.
    #
    # See Expectation for a list of declarators that can be used.
    def should_receive(*args)
      FlexMock.should_receive(args) do |sym|
        unless @methods_proxied.include?(sym)
          hide_existing_method(sym)
          @methods_proxied << sym
        end
        ex = @mock.should_receive(sym)
        ex.mock = self
        ex
      end
    end

    # :call-seq:
    #   new_instances.should_receive(...)
    #   new_instances { |instance|  instance.should_receive(...) }
    #
    # new_instances is a short cut method for overriding the behavior of any
    # new instances created via a mocked class object.
    #
    # By default, new_instances will mock the behaviour of the :new and
    # :allocate methods.  If you wish to mock a different set of class
    # methods, just pass a list of symbols to as arguments.
    #
    # For example, to stub only objects created by :make (and not :new
    # or :allocate), use:
    #
    #    flexmock(ClassName).new_instances(:make).should_receive(...)
    #
    def new_instances(*allocators, &block)
      fail ArgumentError, "new_instances requires a Class to stub" unless Class === @obj
      allocators = [:new, :allocate] if allocators.empty?
      result = ExpectationRecorder.new
      allocators.each do |m|
        self.should_receive(m).and_return { |*args|
          new_obj = invoke_original(m, args)
          mock = mock_container.flexmock(new_obj)
          block.call(mock) if block_given?
          result.apply(mock)
          new_obj
        }
      end
      result
    end

    # any_instance is present for backwards compatibility with version 0.5.0.
    # @deprecated
    def any_instance(&block)
      $stderr.puts "any_instance is deprecated, use new_instances instead."
      new_instances(&block)
    end

    # Invoke the original definition of method on the object supported by
    # the stub.
    def invoke_original(method, args)
      method_proc = @method_definitions[method]
      method_proc.call(*args)
    end
    private :invoke_original

    # Verify that the mock has been properly called.  After verification,
    # detach the mocking infrastructure from the existing object.
    def mock_verify
      @mock.mock_verify
    end

    # Remove all traces of the mocking framework from the existing object.
    def mock_teardown
      if ! detached?
        @methods_proxied.each do |method_name|
          remove_current_method(method_name)
          restore_original_definition(method_name)
        end
        @obj.instance_variable_set("@flexmock_proxy", nil)
        @obj = nil
      end
    end

    # Return the container for this mocking object.  Returns nil if the
    # mock is not in a container.  Mock containers make sure that mock objects
    # inside the container are torn down at the end of a test
    def mock_container
      @mock.mock_container
    end

    # Set the container for this mock object.
    def mock_container=(container)
      @mock.mock_container = container
    end

    private

    # The singleton class of the object.
    def sclass
      class << @obj; self; end
    end

    # Is the current method a singleton method in the object we are
    # mocking?
    def singleton?(method_name)
      @obj.methods(false).include?(method_name.to_s)
    end

    # Hide the existing method definition with a singleton defintion
    # that proxies to our mock object.  If the current definition is a
    # singleton, we need to record the definition and remove it before
    # creating our own singleton method.  If the current definition is
    # not a singleton, all we need to do is override it with our own
    # singleton.
    def hide_existing_method(method_name)
      if @obj.respond_to?(method_name)
        new_alias = new_name(method_name)
        unless @obj.respond_to?(new_alias)
          sclass.class_eval do
            alias_method(new_alias, method_name)
          end
        end
        my_object = @obj
        @method_definitions[method_name] = Proc.new { |*args|
          block = nil
          if Proc === args.last
            block = args.last
            args = args[0...-1]
          end
          my_object.send(new_alias, *args, &block)
        }
      end
      remove_current_method(method_name) if singleton?(method_name)
      define_proxy_method(method_name)
    end

    # Define a proxy method that forwards to our mock object.  The
    # proxy method is defined as a singleton method on the object
    # being mocked.
    def define_proxy_method(method_name)
      sclass.class_eval %{
        def #{method_name}(*args, &block)  @flexmock_proxy.mock.#{method_name}(*args, &block)  end
      }
    end

    # Restore the original singleton defintion for method_name that
    # was saved earlier.
    def restore_original_definition(method_name)
      method_def = @method_definitions[method_name]
      if method_def
        the_alias = new_name(method_name)
        sclass.class_eval do
          alias_method(method_name, the_alias)
        end
      end
    end

    # Remove the current method if it is a singleton method of the
    # object being mocked.
    def remove_current_method(method_name)
      sclass.class_eval { remove_method(method_name) }
    end

    # Have we been detached from the existing object?
    def detached?
      @obj.nil?
    end

    # Generate a name to be used to alias the original behavior.
    def new_name(old_name)
      "flexmock_original_behavior_for_#{old_name}"
    end

  end
end
