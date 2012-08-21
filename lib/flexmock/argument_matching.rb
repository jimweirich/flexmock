class FlexMock
  module ArgumentMatching
    module_function

    def all_match?(expected_args, actual_args)
      return true if expected_args.nil?
      return false if actual_args.size > expected_args.size
      (0...expected_args.size).all? { |i| match?(expected_args[i], actual_args[i]) }
    end

    # Does the expected argument match the corresponding actual value.
    def match?(expected, actual)
      expected === actual ||
      expected == actual ||
      ( Regexp === expected && expected === actual.to_s )
    end
  end
end
