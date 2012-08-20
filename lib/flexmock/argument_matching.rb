class FlexMock
  module ArgumentMatching
    module_function

    def match_args?(expected_args, actual_args)
      # TODO: Rethink this:
      # return false if @expected_args.nil?
      return true if expected_args.nil?
      return false if actual_args.size != expected_args.size
      (0...actual_args.size).all? { |i| match_arg?(expected_args[i], actual_args[i]) }
    end

    # Does the expected argument match the corresponding actual value.
    def match_arg?(expected, actual)
      expected === actual ||
      expected == actual ||
      ( Regexp === expected && expected === actual.to_s )
    end
  end
end
