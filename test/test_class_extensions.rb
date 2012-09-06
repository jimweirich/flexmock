require 'test/test_setup'

class ClassExtensionsTest < Test::Unit::TestCase

  class Dog
    def wag
    end

    def method_missing(sym, *args, &block)
      if sym == :bark
        :woof
      else
        super
      end
    end

    def responds_to?(sym)
      sym == :bark || super
    end
  end

  def test_class_directly_defines_method
    assert Dog.flexmock_defined?(:wag)
  end

  def test_class_indirectly_defines_method
    assert ! Dog.flexmock_defined?(:bark)
  end

  def test_class_does_not_define_method
    assert ! Dog.flexmock_defined?(:jump)
  end

end
