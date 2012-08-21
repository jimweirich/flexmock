class FlexMock
  module ArgumentMatching
    module_function

    MISSING_ARG = Object.new

    def all_match?(expected_args, actual_args)
      return true if expected_args.nil?
      return false if actual_args.size > expected_args.size
      i = 0
      while i < actual_args.size
        return false unless match?(expected_args[i], actual_args[i])
        i += 1
      end
      while i < expected_args.size
        return false unless match?(expected_args[i], MISSING_ARG)
        i += 1
      end
      true
    end

    # Does the expected argument match the corresponding actual value.
    def match?(expected, actual)
      expected === actual ||
      expected == actual ||
      ( Regexp === expected && expected === actual.to_s )
    end

    def missing?(arg)
      arg == MISSING_ARG
    end
  end
end
