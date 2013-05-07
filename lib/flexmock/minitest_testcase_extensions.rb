require "flexmock/generic_testcase_extensions"

module MiniTest
  class Unit
    class TestCase
      GenericTestCase.define_extensions_on(self)
    end
  end
end
