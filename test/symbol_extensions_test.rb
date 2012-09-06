require 'test/test_setup'

class SymbolEtentensionsTest < Test::Unit::TestCase
  def test_as_name_converts_appropriatly
    method_name_class = self.class.instance_methods.first.class
    assert_equal method_name_class, :some_name.flexmock_as_name.class
  end
end
