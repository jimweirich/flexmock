#!/usr/bin/env ruby

require 'flexmock'

class FlexMock
  module MockContainer
    def MockContainer.next_id
      @id_counter ||= 0
      @id_counter += 1
    end

    def flexmodel(model_class, *args, &block)
      id = MockContainer.next_id
      mock = flexmock("#{model_class}_#{id}", *args, &block)
      mock.should_receive(
        :id => id,
        :to_params => id.to_s,
        :new_record? => false,
        :errors => flexmock("errors", :count => 0), 
        :class => model_class)
      mock.should_receive(:is_a?).with(any).and_return { |other|
        other == model_class
      }
      mock
    end
  end
end
