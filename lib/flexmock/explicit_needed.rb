
class FlexMock

  # Expectations on mocks with a base class can only be defined on
  # methods supported by the base class. Attempting to add an stub to
  # a method not defined on the base class will cause the expectation
  # to be wrapped in an ExplicitNeeded wrapper. The wrapper will throw
  # an exception unless the explicitly method is immediately called on
  # the expectation.
  #
  class ExplicitNeeded
    def initialize(expectation, method_name, base_class)
      @expectation = expectation
      @explicit = false
      @method_name = method_name
      @base_class = base_class
    end

    def explicitly
      @explicit = true
      self
    end

    def explicit?
      @explicit
    end

    def mock=(m)
      @expectation.mock = m
    end

    def method_missing(sym, *args, &block)
      if explicit?
        @expectation.send(sym, *args, &block)
      else
        fail NoMethodError, "Cannot stub methods not defined by the base class\n" +
          "   Method:     #{@method_name}\n" +
          "   Base Class: #{@base_class}\n" +
          "   (Use 'explicitly' to override)"
      end
    end
  end
end
