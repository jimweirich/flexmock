
module MiniTest
  class Unit
    class TestCase
      include FlexMock::ArgumentTypes
      include FlexMock::MockContainer

      # Alias the original teardown behavior for later use.
      alias :flexmock_original_teardown :teardown

      # Teardown the test case, verifying any mocks that might have been
      # defined in this test case.
      def teardown
        flexmock_teardown
        flexmock_original_teardown
      end
    end
  end
end
