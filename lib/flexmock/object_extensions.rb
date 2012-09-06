class Object
  def flexmock_singleton_defined?(method_name)
    singleton_methods(false).include?(method_name.flexmock_as_name)
  end
end
