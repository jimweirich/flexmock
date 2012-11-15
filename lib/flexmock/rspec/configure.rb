# Auto configure for RSpec
#
# Just require 'flexmock/rspec/configure' to automatically configure
# RSpec to use flexmock.

if defined?(RSpec)
  RSpec.configure do |config|
    config.mock_with :flexmock
  end
else
  fail "Cannot auto-configure flexmock for ancient versions of rspec"
end
