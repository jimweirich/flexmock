require 'test/test_setup'

class BaseClassTest < Test::Unit::TestCase
  include FlexMock::TestCase

  class FooBar
    def foo
    end

    def method_missing(sym, *args, &block)
      return :poof if sym == :barq
      super
    end

    def respond_to?(method)
      method == :barq || super
    end
  end

  def mock
    @mock ||= flexmock(:on, FooBar)
  end

  def test_base_class_auto_mocks_class
    assert_equal FooBar, mock.class
  end

  def test_base_class_auto_mocks_base_class_methods
    assert_equal FlexMock.undefined, mock.foo
  end

  def test_base_class_does_not_mock_non_base_class_methods
    assert_raise(NoMethodError) do
      mock.fuzz
    end
  end

  def test_can_stub_existing_methods
    mock.should_receive(:foo => :bar)
    assert_equal :bar, mock.foo
  end

  def test_can_not_stub_non_class_defined_methods
    ex = assert_raises(NoMethodError) do
      mock.should_receive(:baz => :bar)
    end
    assert_match(/can *not stub methods.*base.*class/i, ex.message)
    assert_match(/class:.+FooBar/i, ex.message)
    assert_match(/method:.+baz/i, ex.message)
  end

  def test_can_not_stub_non_class_methods_in_single_line
    ex = assert_raises(NoMethodError) do
      flexmock(:on, FooBar, :bark => :value)
    end
    assert_match(/can *not stub methods.*base.*class/i, ex.message)
    assert_match(/class:.+FooBar/i, ex.message)
    assert_match(/method:.+bark/i, ex.message)
  end

  def test_can_explicitly_stub_non_class_defined_methods
    mock.should_receive(:baz).explicitly.and_return(:bar)
    assert_equal :bar, mock.baz
  end

  def test_can_explicitly_stub_meta_programmed_methods
    mock.should_receive(:barq).explicitly.and_return(:bar)
    assert_equal :bar, mock.barq
  end

end
