#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/unit'
require 'flexmock'

class TemperatureSampler
  def initialize(sensor)
    @sensor = sensor
  end

  def average_temp
    total = (0...3).collect { @sensor.read_temperature }.inject { |i, s| i + s }
    total / 3.0
  end
    
end

class TestTemperatureSampler < Test::Unit::TestCase
  def test_tempurature_sampler
    readings = [10, 12, 14]
    mock_sensor = FlexMock.new
    mock_sensor.mock_handle(:read_temperature) { readings.shift }
    sampler = TemperatureSampler.new(mock_sensor)
    assert_equal 12, sampler.average_temp
  end
end
