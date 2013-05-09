class FlexMock

  # This class contains helper methods for mock containers. Since
  # MockContainer is a module that is designed to be mixed into other
  # classes, (particularly testing framework test cases), we don't
  # want to pollute the method namespace of the class that mixes in
  # MockContainer. So we have aggressively moved a number of
  # MockContainer methods out of that class and into
  # MockBuilder to isoloate the names.
  #
  class MockBuilder
    def initialize(container)
      @container = container
    end

    def define_a_mock(location, *args, &block)
      opts = parse_creation_args(args)
      if opts.safe_mode && ! block_given?
        raise UsageError, "a block is required in safe mode"
      end

      result = create_double(opts)
      flexmock_mock_setup(opts.mock, opts, location, &block)
      run_post_creation_hooks(opts, location)
      result
    end

    FlexOpts = Struct.new(
      :name, :defs, :safe_mode, :mock,
      :domain_obj, :base_class,
      :extended, :extended_data
      ) do
      def data
        self.extended_data ||= {}
      end
    end

    # Parse the list of flexmock() arguments and populate the opts object.
    def parse_creation_args(args)
      opts = FlexOpts.new
      while ! args.empty?
        case args.first
        when Symbol
          unless parse_create_symbol(args, opts)
            opts.name = args.shift.to_s
          end
        when String, Symbol
          opts.name = args.shift.to_s
        when Hash
          opts.defs = args.shift
        when FlexMock
          opts.mock = args.shift
        else
          opts.domain_obj = args.shift
        end
      end
      set_base_class(opts)
      opts
    end

    # Create the test double based on the args options.
    def create_double(opts)
      if opts.extended
        result = opts.extended.create(container, opts)
      elsif opts.domain_obj
        result = create_partial(opts)
      else
        result = create_mock(opts)
      end
      opts.mock ||= result
      result
    end

    # Run any post creation hooks specified by an extension.
    def run_post_creation_hooks(opts, location)
      if opts.extended
        opts.extended.post_create(opts, location)
      end
    end


    # Setup the test double with its expections and such.
    def flexmock_mock_setup(mock, opts, location)
      mock.flexmock_based_on(opts.base_class) if opts.base_class
      mock.flexmock_define_expectation(location, opts.defs)
      yield(mock) if block_given?
      container.flexmock_remember(mock)
    end

    attr_reader :container
    private :container

    private

    # Set the base class if not defined and partials are based.
    def set_base_class(opts)
      if ! opts.base_class && opts.domain_obj && FlexMock.partials_are_based
        opts.base_class = opts.domain_obj.class
      end
    end

    # Handle a symbol in the flexmock() args list.
    def parse_create_symbol(args, opts)
      case args.first
      when :base, :safe
        opts.safe_mode = (args.shift == :safe)
        opts.domain_obj = args.shift
      when :on
        args.shift
        opts.base_class = args.shift
        opts.name ||= "#{opts.base_class} Mock"
      else
        CONTAINER_HELPER.extensions.each do |ext|
          handled = ext.handle(args, opts)
          return true if handled
        end
        return false
      end
      true
    end

    # Create a mock object in the options.
    def create_mock(opts)
      opts.mock ||= FlexMock.new(opts.name || "unknown", container)
      opts.mock
    end

    # Create a partial mock object in options.
    def create_partial(opts)
      opts.mock = PartialMockProxy.make_proxy_for(
        opts.domain_obj,
        container, opts.name,
        opts.safe_mode)
      opts.domain_obj
    end

  end

end
