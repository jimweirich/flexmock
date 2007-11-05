#!/usr/bin/env ruby

require 'test/unit'
require 'flexmock/rails/view_mocking'

######################################################################
class TestRailsViewStub < Test::Unit::TestCase
  include FlexMock::TestCase

  def setup
    @controller_class = flexmock("controller class")
    @controller = flexmock("controller", :class => @controller_class)
  end

  def test_view_mocks_as_stub
    should_render_view
    render "controller/new.rthml"
  end

  def test_fails_if_no_render
    should_render_view
    assert_raise(Test::Unit::AssertionFailedError) do
      flexmock_verify
    end
  end

  def test_view_mocks_with_expectation
    should_render_view("new")
    render "controller/new"
  end

  def test_view_mocks_with_expectation_fails_with_different_template
    should_render_view("new")
    render "controller/edit"
    assert_raise(Test::Unit::AssertionFailedError) do
      flexmock_verify
    end
  end

  def test_view_mocks_with_expectation_wand_multiple_templates
    should_render_view("new")
    render "controller/edit", "controller/new", "controller/show"
  end

  private

  def render(*names)
    vc = @controller.class.view_class
    v = vc.new
    v.assigns(:x => :y)
    v.render_file
    v.first_render
    names.each do |name|
      v.file_exists?(name)
    end
  end
end
