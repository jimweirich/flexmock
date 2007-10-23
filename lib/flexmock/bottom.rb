#!/usr/bin/env ruby

#---
# Copyright 2003, 2004, 2005, 2006, 2007 by Jim Weirich (jim@weirichhouse.org).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

class FlexMock

  # Bottom is self preserving undefined object.  The result of any
  # interaction with the bottom object will be the bottom object
  # itself.
  class Bottom 
    def method_missing(sym, *args, &block)
      self
    end

    def to_s
      "BOTTOM"
    end

    def inspect
      to_s
    end

    def clone
      self
    end
    
    def coerce(other)
      [BOTTOM, BOTTOM]
    end
  end

  # Bottom is normally available as FlexMock::BOTTOM
  BOTTOM = Bottom.new
  
  class << Bottom
    private :new
  end
end 
