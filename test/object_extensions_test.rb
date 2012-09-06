#!/usr/bin/env ruby

require 'test/test_setup'
require 'flexmock/object_extensions'

class ObjectExtensionsTest < Test::Unit::TestCase
  def setup
    @obj = Object.new
    def @obj.smethod
      :ok
    end
  end

  def test_undefined_methods_are_not_singletons
    assert ! @obj.flexmock_singleton_defined?(:xyzzy)
  end

  def test_normal_methods_are_not_singletons
    assert ! @obj.flexmock_singleton_defined?(:to_s)
  end

  def test_singleton_methods_are_singletons
    assert @obj.flexmock_singleton_defined?(:smethod)
  end
end
