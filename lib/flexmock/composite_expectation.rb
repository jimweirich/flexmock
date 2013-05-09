class FlexMock

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
      @expectations.first.mock.
        flexmock_define_expectation(caller.first, *args, &block)
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

end
