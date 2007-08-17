#!/usr/bin/env ruby

require 'test/unit'

class DummyModel
end

######################################################################
class TestFlexModel < Test::Unit::TestCase
  include FlexMock::TestCase

  def test_initial_conditions
    model = flexmock(:model, DummyModel)
    assert_match(/^DummyModel_\d+/, model.mock_name)
    assert_equal model.id.to_s, model.to_params
    assert ! model.new_record?
    assert model.is_a?(DummyModel)
    assert_equal DummyModel, model.class
  end

  def test_mock_models_have_different_ids
    m1 = flexmock(:model, DummyModel)
    m2 = flexmock(:model, DummyModel)
    assert m2.id != m1.id
  end

  def test_mock_models_can_have_quick_defs
    model = flexmock(:model, DummyModel, :xyzzy => :ok)
    assert_equal :ok, model.xyzzy
  end

  def test_mock_models_can_have_blocks
    model = flexmock(:model, DummyModel) do |m|
      m.should_receive(:xyzzy => :okdokay)
    end
    assert_equal :okdokay, model.xyzzy
  end
end
