#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/noop'
require 'flexmock/expectation_builder'

class FlexMock

  # PartialMockProxy is used to mate the mock framework to an existing
  # object. The object is "enhanced" with a reference to a mock object
  # (stored in <tt>@flexmock_proxy</tt>). When the +should_receive+
  # method is sent to the proxy, it overrides the existing object's
  # method by creating singleton method that forwards to the mock.
  # When testing is complete, PartialMockProxy will erase the mocking
  # infrastructure from the object being mocked (e.g. remove instance
  # variables and mock singleton methods).
  #
  class PartialMockProxy
    include Ordering

    attr_reader :mock

    # Make a partial mock proxy and install it on the target +obj+.
    def self.make_proxy_for(obj, container, name, safe_mode)
      name ||= "flexmock(#{obj.class.to_s})"
      if ! proxy_defined_on?(obj)
        mock = FlexMock.new(name, container)
        proxy = PartialMockProxy.new(obj, mock, safe_mode)
        obj.instance_variable_set("@flexmock_proxy", proxy)
      end
      obj.instance_variable_get("@flexmock_proxy")
    end

    # Is there a mock proxy defined on the domain object?
    def self.proxy_defined_on?(obj)
      obj.instance_variable_defined?("@flexmock_proxy") &&
        obj.instance_variable_get("@flexmock_proxy")
    end

    # The following methods are added to partial mocks so that they
    # can act like a mock.

    MOCK_METHODS = [
      :should_receive, :new_instances,
      :should_receive_with_location,
      :flexmock_get,   :flexmock_teardown, :flexmock_verify,
      :flexmock_received?, :flexmock_calls, :flexmock_find_expectation
    ]

    # Initialize a PartialMockProxy object.
    def initialize(obj, mock, safe_mode)
      @obj = obj
      @mock = mock
      @method_definitions = {}
      @methods_proxied = []
      unless safe_mode
        add_mock_method(:should_receive)
        MOCK_METHODS.each do |sym|
          unless @obj.respond_to?(sym)
            add_mock_method(sym)
          end
        end
      end
    end

    # Get the mock object for the partial mock.
    def flexmock_get
      @mock
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
      location = caller.first
      flexmock_define_expectation(location, *args)
    end

    def flexmock_define_expectation(location, *args)
      EXP_BUILDER.parse_should_args(self, args) do |method_name|
        unless @methods_proxied.include?(method_name)
          hide_existing_method(method_name)
        end
        ex = @mock.flexmock_define_expectation(location, method_name)
        ex.mock = self
        ex
      end
    end

    def flexmock_find_expectation(*args)
      @mock.flexmock_find_expectation(*args)
    end

    def add_mock_method(method_name)
      stow_existing_definition(method_name)
      target_class_eval do
        define_method(method_name) { |*args, &block|
          proxy = instance_variable_get("@flexmock_proxy") or
            fail "Missing FlexMock proxy " +
                 "(for method_name=#{method_name.inspect}, self=\#{self})"
          proxy.send(method_name, *args, &block)
        }
      end
    end

    # :call-seq:
    #   new_instances.should_receive(...)
    #   new_instances { |instance|  instance.should_receive(...) }
    #
    # new_instances is a short cut method for overriding the behavior of any
    # new instances created via a mocked class object.
    #
    # By default, new_instances will mock the behaviour of the :new
    # method.  If you wish to mock a different set of class methods,
    # just pass a list of symbols to as arguments.  (previous versions
    # also mocked :allocate by default.  If you need :allocate to be
    # mocked, just request it explicitly).
    #
    # For example, to stub only objects created by :make (and not
    # :new), use:
    #
    #    flexmock(ClassName).new_instances(:make).should_receive(...)
    #
    def new_instances(*allocators, &block)
      fail ArgumentError, "new_instances requires a Class to stub" unless
        Class === @obj
      location = caller.first
      allocators = [:new] if allocators.empty?
      expectation_recorder = ExpectationRecorder.new
      allocators.each do |allocate_method|
        check_allocate_method(allocate_method)
        flexmock_define_expectation(location, allocate_method).and_return { |*args|
          create_new_mocked_object(
            allocate_method, args, expectation_recorder, block)
        }
      end
      expectation_recorder
    end

    # Create a new mocked object.
    #
    # The mocked object is created using the following steps:
    # (1) Allocate with the original allocation method (and args)
    # (2) Pass to the block for custom configuration.
    # (3) Apply any recorded expecations
    #
    def create_new_mocked_object(allocate_method, args, recorder, block)
      new_obj = flexmock_invoke_original(allocate_method, args)
      mock = flexmock_container.flexmock(new_obj)
      block.call(mock) unless block.nil?
      recorder.apply(mock)
      new_obj
    end
    private :create_new_mocked_object

    # Invoke the original definition of method on the object supported by
    # the stub.
    def flexmock_invoke_original(method, args)
      method_proc = @method_definitions[method]
      method_proc.call(*args)
    end

    # Verify that the mock has been properly called.  After verification,
    # detach the mocking infrastructure from the existing object.
    def flexmock_verify
      @mock.flexmock_verify
    end

    # Remove all traces of the mocking framework from the existing object.
    def flexmock_teardown
      if ! detached?
        @methods_proxied.each do |method_name|
          remove_current_method(method_name)
          restore_original_definition(method_name)
        end
        @obj.instance_variable_set("@flexmock_proxy", nil)
        @obj = nil
      end
    end

    # Forward to the mock's container.
    def flexmock_container
      @mock.flexmock_container
    end

    # Forward to the mock
    def flexmock_received?(*args)
      @mock.flexmock_received?(*args)
    end

    # Forward to the mock
    def flexmock_calls
      @mock.flexmock_calls
    end

    # Set the proxy's mock container.  This set value is ignored
    # because the proxy always uses the container of its mock.
    def flexmock_container=(container)
    end

    # Forward the request for the expectation director to the mock.
    def flexmock_expectations_for(method_name)
      @mock.flexmock_expectations_for(method_name)
    end

    # Forward the based on request.
    def flexmock_based_on(*args)
      @mock.flexmock_based_on(*args)
    end

    private

    def check_allocate_method(allocate_method)
      if allocate_method == :allocate && RUBY_VERSION >= "1.9"
        fail UsageError,
          "Cannot mock the allocation method using new_instances in Ruby 1.9"
      end
    end

    # The singleton class of the object.
    def target_singleton_class
      class << @obj; self; end
    end

    # Evaluate a block (or string) in the context of the singleton
    # class of the target partial object.
    def target_class_eval(*args, &block)
      target_singleton_class.class_eval(*args, &block)
    end

    def singleton?(method_name)
      @obj.flexmock_singleton_defined?(method_name)
    end

    # Hide the existing method definition with a singleton defintion
    # that proxies to our mock object.  If the current definition is a
    # singleton, we need to record the definition and remove it before
    # creating our own singleton method.  If the current definition is
    # not a singleton, all we need to do is override it with our own
    # singleton.
    def hide_existing_method(method_name)
      stow_existing_definition(method_name)
      define_proxy_method(method_name)
    end

    # Stow the existing method definition so that it can be recovered
    # later.
    def stow_existing_definition(method_name)
      @methods_proxied << method_name
      new_alias = create_alias_for_existing_method(method_name)
      if new_alias
        @method_definitions[method_name] = create_aliased_definition(@obj, new_alias)
      end
      remove_current_method(method_name) if singleton?(method_name)
    end

    # Create a method definition that invokes the original behavior
    # via the alias.
    def create_aliased_definition(my_object, new_alias)
      Proc.new { |*args|
        block = nil
        if Proc === args.last
          block = args.last
          args = args[0...-1]
        end
        my_object.send(new_alias, *args, &block)
      }
    end
    private :create_aliased_definition

    # Create an alias for the existing +method_name+.  Returns the new
    # alias name.  If the aliasing process fails (because the method
    # doesn't really exist, then return nil.
    def create_alias_for_existing_method(method_name)
      new_alias = new_name(method_name)
      unless @obj.respond_to?(new_alias)
        safe_alias_method(new_alias, method_name)
      end
      new_alias
    end

    # Create an alias for the existing method named +method_name+. It
    # is possible that +method_name+ is implemented via a
    # meta-programming, so we provide for the case that the
    # method_name does not exist.
    def safe_alias_method(new_alias, method_name)
      target_class_eval do
        begin
          alias_method(new_alias, method_name)
        rescue NameError
          nil
        end
      end
    end

    # Define a proxy method that forwards to our mock object.  The
    # proxy method is defined as a singleton method on the object
    # being mocked.
    def define_proxy_method(method_name)
      if method_name.to_s =~ /=$/
        eval_line = __LINE__ + 1
        target_class_eval %{
          def #{method_name}(*args, &block)
            instance_variable_get('@flexmock_proxy').
              mock.__send__(:#{method_name}, *args, &block)
          end
        }, __FILE__, eval_line
      else
        eval_line = __LINE__ + 1
        target_class_eval %{
          def #{method_name}(*args, &block)
            instance_variable_get('@flexmock_proxy').
              mock.#{method_name}(*args, &block)
          end
        }, __FILE__, eval_line
        _ = true       # make rcov recognize the above eval is covered
      end
    end

    # Restore the original singleton defintion for method_name that
    # was saved earlier.
    def restore_original_definition(method_name)
      begin
        method_def = @method_definitions[method_name]
        if method_def
          the_alias = new_name(method_name)
          target_class_eval do
            alias_method(method_name, the_alias)
          end
        end
      rescue NameError => _
        # Alias attempt failed
        nil
      end
    end

    # Remove the current method if it is a singleton method of the
    # object being mocked.
    def remove_current_method(method_name)
      target_class_eval { remove_method(method_name) }
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
