require 'flexmock/rspec'

RSpec.configure do |config|
  config.mock_with :flexmock
end

describe "Dog" do
  class Dog
    def wags(arg)
      fail "SHOULD NOT BE CALLED"
    end

    def barks
      fail "SHOULD NOT BE CALLED"
    end
  end

  let(:dog) { flexmock(:on, Dog) }

  context "single calls with arguments" do
    before do
      dog.wags(:tail)
    end

    it "wags the tail" do
      dog.should have_received(:wags).with(:tail)
    end

    it "does not bark the tail" do
      dog.should_not have_received(:bark)
    end

    it "rejects wag(:foot)" do
      should_fail(/^expected wag\(:foot\) to be received by <FlexMock:Dog Mock>/i) do
        dog.should have_received(:wag).with(:foot)
      end
    end

    it "rejects not wag(:tail)" do
      should_fail(/^expected wag\(:foot\) to be received by <FlexMock:Dog Mock>/i) do
        dog.should_not have_received(:wag).with(:tail)
      end
    end
  end

  context "multiple calls with multiple arguments" do
    before do
      dog.wags(:tail)
      dog.wags(:tail)
      dog.wags(:tail)
      dog.wags(:head, :tail)
      dog.barks
      dog.barks
    end

    it "accepts wags(:tail) multiple times" do
      dog.should have_received(:wags).with(:tail).times(3)
    end

    it "rejects wags(:tail) wrong times value" do
      should_fail(/^expected wags\(:tail\) to be received by <FlexMock:Dog Mock>/i) do
        dog.should have_received(:wags).with(:tail).times(2)
      end
    end

    it "detects any_args" do
      dog.should have_received(:wags).times(4)
    end

    it "accepts once" do
      dog.should have_received(:wags).with(:head, :tail).once
    end

    it "rejects an incorrect once" do
      should_fail(/^expected wags\(:tail\) to be received by <FlexMock:Dog Mock> once/i) do
        dog.should have_received(:wags).with(:tail).once
      end
    end

    it "accepts twice" do
      dog.should have_received(:barks).twice
    end

    it "rejects an incorrect twice" do
      should_fail(/^expected wags\(:tail\) to be received by <FlexMock:Dog Mock> twice/) do
        dog.should have_received(:wags).with(:tail).twice
      end
    end

    it "accepts never" do
      dog.should have_received(:jump).never
    end

    it "rejects an incorrect never" do
      should_fail(/^expected barks\(\) to be received by <FlexMock:Dog Mock> never/i) do
        dog.should have_received(:barks).with().never
      end
    end

    it "rejects an incorrect never" do
      dog.should_not have_received(:jump)
    end
  end

  context "with blocks" do
    before do
      dog.wags { }
      dog.barks
    end

    it "accepts wags with a block" do
      dog.should have_received(:wags).with_a_block
      dog.should have_received(:wags)
    end

    it "accepts barks without a block" do
      dog.should have_received(:barks).without_a_block
      dog.should have_received(:barks)
    end

    it "rejects wags without a block" do
      should_fail(/without a block/) do
        dog.should have_received(:wags).without_a_block
      end
    end

    it "rejects barks with a block" do
      should_fail(/with a block/) do
        dog.should have_received(:wags).with_a_block
      end
    end
  end

  def should_fail(message_pattern)
    begin
      yield
    rescue RSpec::Expectations::ExpectationNotMetError => ex
      ex.message.should match(message_pattern)
    end
  end
end
