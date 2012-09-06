# Detecting whether a class has a definition for a method or not
# changes between Ruby 1.8 and Ruby 1.9. We introduce the
# "flexmock_defines?" method on class objects to have a portable way
# to determine that.
#
# NOTE: responds_to? isn't appropriate. We don't care if the object
#       responds to the method or not. We want to know if the class
#       has a definition for the method. A subtle difference.
#
class Class

  case instance_methods.first
  when Symbol
    # Instance methods are symbols, compare directly.
    def flexmock_defines?(sym)
      instance_methods.include?(sym)
    end

  when String
    # Instance methods are strings, convert symbol to string first.
    def flexmock_defines?(sym)
      sym = sym.to_s
      instance_methods.include?(sym)
    end
  end

end
