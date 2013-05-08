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
            exp = build_demeter_chain(mock, k, &block).and_return(v)
            result.add(exp)
          end
        when Symbol, String
          result.add(build_demeter_chain(mock, arg, &block))
        end
      end
      result
    end

    # Build the chain of mocks for demeter style mocking.
    #
    # Warning: Nasty code ahead.
    #
    # This method builds a chain of mocks to support demeter style
    # mocking.  Given a mock chain of "first.second.third.last", we
    # must build a chain of mock methods that return the next mock in
    # the chain.  The expectation for the last method of the chain is
    # returned as the result of the method.
    #
    # Things to consider:
    #
    # (1) The expectation for the "first" method must be created by
    # the proper mechanism, which is supplied by the block parameter
    # "block".  In other words, first expectation is created by
    # calling the block.  (This allows us to create expectations on
    # both pure mocks and partial mocks, with the block handling the
    # details).
    #
    # (2) Although the first mock is arbitrary, the remaining mocks in
    # the chain will always be pure mocks created specifically for
    # this purpose.
    #
    # (3) The expectations for all methods but the last in the chain
    # will be setup to expect no parameters and to return the next
    # mock in the chain.
    #
    # (4) It could very well be the case that several demeter chains
    # will be defined on a single mock object, and those chains could
    # share some of the same methods (e.g. "mock.one.two.read" and
    # "mock.one.two.write" both share the methods "one" and "two").
    # It is important that the shared methods return the same mocks in
    # both chains.
    #
    def build_demeter_chain(mock, name_chain, &block)
      names = name_chain.to_s.split('.').map { |n| n.to_sym }
      check_method_names(names)
      if names.size == 1
        build_single_mock(mock, names.first, block)
      else
        build_real_demeter_chain(mock, names, block)
      end
    end

    def build_single_mock(mock, method_name, block)
      block.call(method_name)
    end

    def build_real_demeter_chain(mock, names, block)
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

    def xbuild_real_demeter_chain(mock, names, block)
      fail "NOT IN USE"
      container = mock.flexmock_container
      method_name = names.shift.to_sym
      exp = mock.flexmock_find_expectation(method_name)
      need_new_exp = exp.nil? || names.empty?
      exp = block.call(method_name) if need_new_exp
      while ! names.empty?
        if need_new_exp
          mock = container.flexmock("demeter_#{method_name}")
          exp.with_no_args.and_return(mock)
        else
          mock = exp._return_value([])
        end
        check_proper_mock(mock, method_name)
        method_name = names.shift.to_sym
        exp = mock.flexmock_find_expectation(method_name) || mock.should_receive(method_name)
      end
      exp
    end

    # Check that the given mock is a real FlexMock mock.
    def check_proper_mock(mock, method_name)
      unless mock.kind_of?(FlexMock)
        fail FlexMock::UsageError,
          "Conflicting mock declaration for '#{method_name}' in demeter style mock"
      end
    end

    # CHECK: It seems this regex matches the null method name. I
    # wonder if that's intended.
    METHOD_NAME_RE = /^([A-Za-z_][A-Za-z0-9_]*[=!?]?|\[\]=?|\*\*|<<|>>|<=>|[<>=!]=|[=!]~|===|[-+]@|[-+\*\/%&^|<>~`!])$/

    # Check that all the names in the list are valid method names.
    def check_method_names(names)
      names.each do |name|
        fail FlexMock::UsageError, "Ill-formed method name '#{name}'" if
          name !~ METHOD_NAME_RE
      end
    end
  end

  EXP_BUILDER = ExpectationBuilder.new
end
