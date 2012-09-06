# Detecting whether a class has a definition for a method or not
# changes between Ruby 1.8 and Ruby 1.9. We introduce the
# "flexmock_defined?" method on class objects to have a portable way
# to determine that.
#
# NOTE: responds_to? isn't appropriate. We don't care if the object
#       responds to the method or not. We want to know if the class
#       has a definition for the method. A subtle difference.
#
class Class

  # Does a class directly define a method named "method_name"?
  def flexmock_defined?(method_name)
    instance_methods.include?(method_name.flexmock_as_name)
  end

end
