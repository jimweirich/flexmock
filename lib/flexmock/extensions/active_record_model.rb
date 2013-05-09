require 'flexmock/mock_container'

class FlexMock
  module Extensions

    class ActiveRecordModel
      # Handle the argument list.
      #
      # This method is called whenever an unrecognized symbol is
      # detected in the flexmock argument list. If the extension class
      # can handle it, it should return true.
      #
      # Extension data can be stored in the opts.data hash for later use
      # during the create and post_create phase.
      def handle(args, opts)
        return false unless args.first == :model
        args.shift
        opts.data[:model_class] = args.shift
        opts.extended = self
        true
      end

      # Create the test double.
      #
      # Create the custome test double according to the data from the
      # argument list. The object returned from this method is the
      # object returned from the original flexmock() method call. This
      # the returned object is NOT the actual mock object (which is the
      # case for things like partial proxies), then the opts.mock field
      # should be set to contain the actual mock object.
      def create(container, opts)
        id = next_id
        FlexMock.new("#{opts.data[:model_class]}_#{id}", container)
      end

      # Do any post-creation setup on the mock object.
      def post_create(opts, location)
        add_model_methods(opts.mock, opts.data[:model_class], location)
      end

      private

      # Return the next id for mocked models.
      def next_id
        @id_counter ||= 10000
        @id_counter += 1
      end

      def current_id
        @id_counter
      end

      # Automatically add mocks for some common methods in ActiveRecord
      # models.
      def add_model_methods(mock, model_class, location)
        add_model_methods_returning_values(mock, location,
          [:id,          current_id                                 ],
          [:to_params,   current_id.to_s                            ],
          [:new_record?, false                                      ],
          [:class,       model_class                                ],
          [:errors,      make_mock_model_errors_for(mock, location) ])

        add_model_methods_with_behavior(mock, location,
          [:is_a?,        lambda { |other| other == model_class }                  ],
          [:instance_of?, lambda { |other| other == model_class }                  ],
          [:kind_of?,     lambda { |other| model_class.ancestors.include?(other) } ])
      end

      def add_model_methods_returning_values(mock, location, *pairs)
        pairs.each do |method, retval|
          make_default_behavior(mock, location, method, retval)
        end
      end

      def add_model_methods_with_behavior(mock, location, *pairs)
        pairs.each do |method, block|
          make_default_behavior(mock, location, method, &block)
        end
      end

      # Create a mock model errors object (with default behavior).
      def make_mock_model_errors_for(mock, location)
        result = mock.flexmock_container.flexmock("errors")
        make_default_behavior(result, location, :count, 0)
        make_default_behavior(result, location, :full_messages, [])
        result
      end

      # Define default behavior on a mock object.
      #
      # If a block is given, use that to define the behavior. Otherwise
      # return the +retval+ value.
      def make_default_behavior(mock, location, method, retval=nil, &block)
        if block_given?
          mock.flexmock_define_expectation(location, method).
            with(FlexMock.any).
            and_return(&block).
            by_default
        else
          mock.flexmock_define_expectation(location, method).
            and_return(retval).
            by_default
        end
      end
    end

    FlexMock::CONTAINER_HELPER.add_extension(ActiveRecordModel.new)
  end
end
