class Symbol

  case instance_methods.first
  when Symbol
    def flexmock_as_name
      self
    end

  when String
    def flexmock_as_name
      to_s
    end

  else
    fail "Unexpected class for method list #{instance_methods.first.class}"
  end
end
