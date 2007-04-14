#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/unit'
require 'fileutils'
require 'flexmock'

class TestStubbing < Test::Unit::TestCase
  include FlexMock::TestCase
  
  class Dog
    def bark
      :woof
    end
    def Dog.create
      :new_dog
    end
  end

  def test_stub_command_add_behavior_to_arbitrary_objects
    obj = Object.new
    flexmock(obj).should_receive(:hi).once.and_return(:stub_hi)
    assert_equal :stub_hi, obj.hi
  end
  
  def test_stub_command_can_configure_via_block
    obj = Object.new
    flexmock(obj) do |m|
      m.should_receive(:hi).once.and_return(:stub_hi)
    end
    assert_equal :stub_hi, obj.hi
  end
  
  def test_stubbed_methods_can_take_blocks
    obj = Object.new
    flexmock(obj).should_receive(:with_block).once.with(Proc).
      and_return { |block| block.call }
    assert_equal :block, obj.with_block { :block }
  end
  
  def test_multiple_stubs_on_the_same_object_reuse_the_same_partial_mock
    obj = Object.new
    assert_equal flexmock(obj), flexmock(obj)
  end
  
  def test_multiple_methods_can_be_stubbed
    dog = Dog.new
    flexmock(dog).should_receive(:bark).and_return(:grrrr)
    flexmock(dog).should_receive(:wag).and_return(:happy)
    assert_equal :grrrr, dog.bark
    assert_equal :happy, dog.wag
  end
  
  def test_original_behavior_can_be_restored
    dog = Dog.new
    partial_mock = flexmock(dog)
    partial_mock.should_receive(:bark).once.and_return(:growl)
    assert_equal :growl, dog.bark
    partial_mock.mock_teardown
    assert_equal :woof, dog.bark
    assert_equal nil, dog.instance_variable_get("@flexmock_proxy")
  end
  
  def test_original_missing_behavior_can_be_restored
    obj = Object.new
    partial_mock = flexmock(obj)
    partial_mock.should_receive(:hi).once.and_return(:ok)
    assert_equal :ok, obj.hi
    partial_mock.mock_teardown
    assert_raise(NoMethodError) { obj.hi }
  end

  def test_multiple_stubs_on_single_method_can_be_restored_missing_method
    obj = Object.new
    partial_mock = flexmock(obj)
    partial_mock.should_receive(:hi).with(1).once.and_return(:ok)
    partial_mock.should_receive(:hi).with(2).once.and_return(:ok)
    assert_equal :ok, obj.hi(1)
    assert_equal :ok, obj.hi(2)
    partial_mock.mock_teardown
    assert_raise(NoMethodError) { obj.hi }
  end
  
  def test_original_behavior_is_restored_when_multiple_methods_are_mocked
    dog = Dog.new
    flexmock(dog).should_receive(:bark).and_return(:grrrr)
    flexmock(dog).should_receive(:wag).and_return(:happy)
    flexmock(dog).mock_teardown
    assert_equal :woof, dog.bark
    assert_raise(NoMethodError) { dog.wag }
  end

  def test_original_behavior_is_restored_on_class_objects
    flexmock(Dog).should_receive(:create).once.and_return(:new_stub)
    assert_equal :new_stub, Dog.create
    flexmock(Dog).mock_teardown
    assert_equal :new_dog, Dog.create    
  end

  def test_original_behavior_is_restored_on_singleton_methods
    obj = Object.new
    def obj.hi() :hello end
    flexmock(obj).should_receive(:hi).once.and_return(:hola)

    assert_equal :hola, obj.hi
    flexmock(obj).mock_teardown
    assert_equal :hello, obj.hi
  end

  def test_original_behavior_is_restored_on_singleton_methods_with_multiple_stubs
    obj = Object.new
    def obj.hi(n) "hello#{n}" end
    flexmock(obj).should_receive(:hi).with(1).once.and_return(:hola)
    flexmock(obj).should_receive(:hi).with(2).once.and_return(:hola)

    assert_equal :hola, obj.hi(1)
    assert_equal :hola, obj.hi(2)
    flexmock(obj).mock_teardown
    assert_equal "hello3", obj.hi(3)
  end

  def test_original_behavior_is_restored_on_nonsingleton_methods_with_multiple_stubs
    flexmock(Dir).should_receive(:chdir).with("xx").once.and_return(:ok1)
    flexmock(Dir).should_receive(:chdir).with("yy").once.and_return(:ok2)
    assert_equal :ok1, Dir.chdir("xx")
    assert_equal :ok2, Dir.chdir("yy")

    flexmock(Dir).mock_teardown

    x = :not_called
    Dir.chdir("test") do
      assert_match %r{/test$}, Dir.pwd
      x = :called
    end
    assert_equal :called, x
  end

  def test_stubbing_file_shouldnt_break_writing
    flexmock(File).should_receive(:open).with("foo").once.and_return(:ok)
    assert_equal :ok, File.open("foo")
    flexmock(File).mock_teardown

    File.open("dummy.txt", "w") do |out|
      assert out.is_a?(IO)
      out.puts "XYZ"
    end
    text = nil
    File.open("dummy.txt") { |f| text = f.read }
    assert_equal "XYZ\n", text
  ensure
    FileUtils.rm_f("dummy.txt")
  end

  def test_original_behavior_is_restored_even_when_errors
    flexmock(Dog).should_receive(:create).once.and_return(:mock)
    flexmock_teardown rescue nil
    assert_equal :new_dog, Dog.create

    # Now disable the mock so that it doesn't cause errors on normal
    # test teardown
    m = flexmock(Dog).mock
    def m.mock_verify() end
  end

  def test_not_calling_stubbed_method_is_an_error
    dog = Dog.new
    flexmock(dog).should_receive(:bark).once
    assert_raise(Test::Unit::AssertionFailedError) { 
      flexmock(dog).mock_verify
    }
    dog.bark
  end

  def test_mock_is_verified_when_the_stub_is_verified
    obj = Object.new
    partial_mock = flexmock(obj)
    partial_mock.should_receive(:hi).once.and_return(:ok)
    assert_raise(Test::Unit::AssertionFailedError) { 
      partial_mock.mock_verify
    }
  end
  
  def test_stub_can_have_explicit_name
    obj = Object.new
    partial_mock = flexmock(obj, "Charlie")
    assert_equal "Charlie", partial_mock.mock.mock_name
  end

  def test_unamed_stub_will_use_default_naming_convention
    obj = Object.new
    partial_mock = flexmock(obj)
    assert_equal "flexmock(Object)", partial_mock.mock.mock_name
  end
  
end
