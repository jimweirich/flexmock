#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

class FlexMock

  # A CallValidator checks the list of call records for a particular
  # method name and arguments.
  class CallValidator

    # Does the +calls+ list record a method named +method_name+ with
    # +args+.  Options include:
    #
    # * :times => n    -- If given, the call should match exactly +n+ times.
    # * :and => []     -- A list of argument validations to be run on each
    #                     matching invocation.
    # * :on_count => n -- If given, the :and validations on only run on the
    #                     nth invocation.
    #
    def received?(calls, method_name, args, options)
      count = 0
      calls.each { |call_record|
        if call_record.matches?(method_name, args, options)
          count += 1
          run_additional_validations(call_record, count, options)
        end
      }
      count_matches?(count, options[:times])
    end

    private

    def additionals(options)
      ands = options[:and]
      if ands.nil?
        []
      elsif ands.is_a?(Proc)
        [ands]
      else
        ands
      end
    end

    def run_additional_validations(call_record, count, options)
      if options[:on_count].nil? || count == options[:on_count]
        additionals(options).each do |add|
          add.call(*call_record.args)
        end
      end
    end

    def count_matches?(count, times)
      if times
        count == times
      else
        count > 0
      end
    end
  end

end
