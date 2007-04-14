#!/usr/bin/env ruby
#
#  Created by Jim Weirich on 2007-04-10.
#  Copyright (c) 2007. All rights reserved.

Spec::Runner.configure do |config|
   config.mock_with :flexmock
end

context "FlexMock in a RSpec example" do
  specify "should be able to create a mock" do
    m = flexmock()
  end
  
  specify "should have an error when a mock is not called" do
    m = flexmock("Expectation Failured")
    m.should_receive(:hi).with().once
  end
  
  specify "should be able to create a stub" do
    s = "Hello World"
    flexmock(:base, s).should_receive(:downcase).with().once.and_return("hello WORLD")
    
    s.downcase.should == "hello WORLD"
  end
  
  specify "Should show an example failure" do
    1.should == 2
  end
end