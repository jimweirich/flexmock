#!/usr/bin/env ruby

#---
# Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

class FlexMock

  # An expectation recorder records any expectations received and plays them
  # back on demand.  This is used to collect the expectations in the blockless
  # version of the new_instances call.
  #
  class ExpectationRecorder

    # Initialize the recorder.
    def initialize
      @expectations = []
    end

    # Save any incoming messages to be played back later.
    def method_missing(sym, *args, &block)
      @expectations << [sym, args, block]
      self
    end

    # Apply the recorded messages to the given object in a chaining fashion
    # (i.e. the result of the previous call is used as the target of the next
    # call).
    def apply(mock)
      obj = mock
      @expectations.each do |sym, args, block|
        obj = obj.send(sym, *args, &block)
      end
    end
  end

end
