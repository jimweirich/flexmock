# Flex Mock -- Making Mocking Easy

FlexMock is a simple, but flexible, mock object library for Ruby unit
testing.

Version :: 1.3.1

# Links

* **Documents** -- http://flexmock.rubyforge.org
* **RubyGems**   -- Install with: `gem install flexmock`
* **Source** -- https://github.com/jimweirich/flexmock
* **Bug Reports / Issue Tracking** -- https://github.com/jimweirich/flexmock/issues
* **Continuous Integration** -- http://travis-ci.org/#!/jimweirich/flexmock

## Installation

You can install FlexMock with the following command.

```
 $ gem install flexmock
```

## Simple Example

We have a data acquisition class (<code>TemperatureSampler</code>)
that reads a temperature sensor and returns an average of 3 readings.
We don't have a _real_ temperature to use for testing, so we mock one
up with a mock object that responds to the
`read_temperature` message.

Here's the complete example:

```ruby
  require 'test/unit'
  require 'flexmock/test_unit'

  class TemperatureSampler
    def initialize(sensor)
      @sensor = sensor
    end

    def average_temp
      total = (0...3).collect {
        @sensor.read_temperature
      }.inject { |i, s| i + s }
      total / 3.0
    end
  end

  class TestTemperatureSampler < Test::Unit::TestCase
    def test_sensor_can_average_three_temperature_readings
      sensor = flexmock("temp")
      sensor.should_receive(:read_temperature).times(3).
        and_return(10, 12, 14)

      sampler = TemperatureSampler.new(sensor)
      assert_equal 12, sampler.average_temp
    end
  end
```

You can find an extended example of FlexMock in
[Google Example](http://flexmock.rubyforge.org/files/doc/GoogleExample_rdoc.html
"Example").

## Test::Unit Integration

FlexMock integrates nicely with Test::Unit. Just require the
'flexmock/test_unit' file at the top of your test file. The
`flexmock` method will be available for mock creation, and
any created mocks will be automatically validated and closed at the
end of the individual test.

Your test case will look something like this:

```ruby
  require 'flexmock/test_unit'

  class TestDog < Test::Unit::TestCase
    def test_dog_wags
      tail_mock = flexmock(:wag => :happy)
      assert_equal :happy, tail_mock.wag
    end
  end
```

**NOTE:** If you don't want to automatically extend every TestCase
with the flexmock methods and overhead, then require the 'flexmock'
file and explicitly include the FlexMock::TestCase module in each test
case class where you wish to use mock objects. FlexMock versions prior
to 0.6.0 required the explicit include.

## RSpec Integration

FlexMock also supports integration with the RSpec behavior
specification framework.  Starting with version 0.9.0 of RSpec, you
will be able to say:

```ruby
  RSpec.configure do |config|
    config.mock_with :flexmock
  end

  describe "Using FlexMock with RSpec" do
    it "should be able to create a mock" do
      m = flexmock(:foo => :bar)
      m.foo.should === :bar
    end
  end
```

**NOTE:** _I often can't remember the proper RSpec configuration for
flexmock without looking it up. If you are the same, you can put
<code>require 'flexmock/rspec/configure'</code> in your spec helper to
auto-configure RSpec to use flexmock._

**NOTE:** _Older versions of RSpec used the Spec::Runner for
configuration. If you are running with a very old RSpec, you may need
the following:_

```ruby
  # Configuration for RSpec prior to RSpec 2.x
  Spec::Runner.configure do |config|
    config.mock_with :flexmock
  end
```

## Quick Reference

### Creating Mock Objects

The `flexmock` method is used to create mocks in various
configurations. Here's a quick rundown of the most common options. See
FlexMock::MockContainer#flexmock for more details.

* <b>mock = flexmock("joe")</b>

  Create a mock object named "joe" (the name is used in reporting errors).

* <b>mock = flexmock(:foo => :bar, :baz => :froz)</b>

  Create a mock object and define two mocked methods (:foo and :baz)
  that return the values :bar and :froz respectively. This is useful
  when creating mock objects with just a few methods and simple return
  values.

* <b>mock = flexmock("joe", :foo => :bar, :bar => :froz)</b>

  You can combine the mock name and an expectation hash in the same
  call to flexmock.

* <b>mock = flexmock("joe", :on, <em>User</em>)</b>

  This defines a strict mock that is based on the User class. Strict
  mocks prevent you from mocking or stubbing methods that are not
  instance methods of the restricting class (i.e. User in our
  example). This helps prevent tests from becoming stale with
  incorrectly mocked objects when the method names change.

  Use the `explicitly` modifier to `should_receive` to override the
  strict mock restrictions.

* <b>partial_mock = flexmock(<em>real_object</em>)</b>

  If you you give `flexmock` a real object in the argument list, it
  will treat that real object as a base for a partial mock object. The
  return value `partial_mock` may be used to set expectations. The
  real_object should be used in the reference portion of the test.

* <b>partial_mock = flexmock(<em>real_object</em>, :on, <em>class_object</em>)</b>

* <b>partial_mock = flexmock(<em>real_object</em>, :strict)</b>

  Partial mocks can also take a restricting base, so that you cannot
  mock methods not in the class (without the <code>explicitly</code>
  modifier). Since partials already have a class, you can use the
  <code>:strict</code> keyword to mean the same thing as <code>:on,
  <em>real_object</em>.class</code>.

* <b>partial_mock = flexmock(<em>real_object</em>, "name", :foo => :baz)</b>

  Names and expectation hashes may be used with partial mocks as well.

* <b>partial_mock = flexmock(:base, <em>real_string_object</em>)</b>

  Since Strings (and Symbols for that matter) are used for mock names,
  FlexMock will not recognize them as the base for a partial mock. To
  force a string to be used as a partial mock base, proceed the string
  object in the calling sequence with :base.

* <b>partial_mock = flexmock(:safe, <em>real_object</em>) { |mock| mock.should_receive(...) }</b>

  When mocking real objects (i.e. "partial mocks"), FlexMock will add
  a handful of mock related methods to the actual object (see below
  for list of method names). If one or more of these added methods
  collide with an existing method on the partial mock, then there are
  problems.

  FlexMock offers a "safe" mode for partial mocks that does not add
  these methods. Indicate safe mode by passing the symbol :safe as the
  first argument of flexmock. A block _is required_ when using safe
  mode (the partial_mock returned in safe mode does not have a
  `should_receive` method).

  The methods added to partial mocks in non-safe mode are:

  * should_receive
  * new_instances
  * flexmock_get
  * flexmock_teardown
  * flexmock_verify
  * flexmock_received?
  * flexmock_calls

* <b>mock = flexmock(...) { |mock| mock.should_receive(...) }</b>

  If a block is given to any of the `flexmock` forms, the mock object
  will be passed to the block as an argument. Code in the block can
  set the desired expectations for the mock object.

* <b>mock_model = flexmock(:model, <em>YourModel</em>, ...) { |mock| mock.should_receive(...) }</b>

  When given `:model`, `flexmock()` will return a pure mock (not a
  partial mock) that will have some ActiveRecord specific methods
  defined. YourModel should be the class of an ActiveRecord model.
  These predefined methods make it a bit easier to mock out
  ActiveRecord model objects in a Rails application. Other that the
  predefined mocked methods, the mock returned is a standard FlexMock
  mock object.

  The predefined mocked methods are:

  * id -- returns a unique ID for each mocked model.
  * to_params -- returns a stringified version of the id.
  * new_record? -- returns false.
  * errors -- returns an empty (mocked) errors object.
  * is_a?(other) -- returns true if other == YourModel.
  * instance_of?(class) -- returns true if class == YourModel
  * kind_of?(class) -- returns true if class is YourModel or one of its ancestors
  * class -- returns YourModel.

* <b>mock = flexmock(... :on, <em>class_object</em>, ...)</b>

**NOTE:** Versions of FlexMock prior to 0.6.0 used `flexstub` to
create partial mocks. The `flexmock` method now assumes all the
functionality that was spread out between two different methods.
`flexstub` is deprecated, but still available for backward
compatibility.

### Expectation Declarators

Once a mock is created, you need to define what that mock should
expect to see. Expectation declarators are used to specify these
expectations placed upon received method calls. A basic expectation,
created with the `should_receive` method, just establishes the fact
that a method may (or may not) be called on the mock object.
Refinements to that expectation may be additionally declared. FlexMock
always starts with the most general expectation and adds constraints
to that.

For example, the following code:

```ruby
    mock.should_receive(:average).and_return(12)
```

Means that the mock will now accept method calls to an
`average` method. The expectation will accept any arguments
and may be called any number of times (including zero times). Strictly
speaking, the `and_return` part of the declaration isn't
exactly a constraint, but it does specify what value the mock will
return when the expectation is matched.

If you want to be more specific, you need to add additional
constraints to your expectation. Here are some examples:

```ruby
    mock.should_receive(:average).with(12).once

    mock.should_receive(:average).with(Integer).
        at_least.twice.at_most.times(10).
        and_return { rand }
```

Expectation are always matched in order of declaration. That means if
you have a general expectation before a more specific expectation, the
general expectation will have an opportunity to match first,
effectively hiding the second expectation.

For example:

```ruby
    mock.should_receive(:average)              # Matches any call to average
    mock.should_receive(:average).with(1).once # Fails because it never matches
```

In the example, the second expectation will never be triggered because
all calls to average will be handled by the first expectation. Since
the second expectation is require to match one time, this test will
fail.

Reversing the order of the expections so that the more specific
expectation comes first will fix that problem.

If an expectation has a count requirement (e.g. `once` or `times`),
then once it has matched its expected number of times, it will let
other expectations have a chance to match.

For example:

```ruby
    mock.should_receive(:average).once.and_return(1)
    mock.should_receive(:average).once.and_return(2)
    mock.should_receive(:average).and_return(3)
```

In the example, the first time average is called, the first
expectation is matched an average will return 1. The second time
average is called, the second expectation matches and 2 is returned.
For all calls to average after that, the third expectation returning 3
will be used.

Occasionally it is useful define a set of expecations in a setup
method of a test and override those expectations in specific tests. If
you mark an expectation with the `by_default` marker, that expectation
will be used only if there are no non-default expectations on that
method name. See "by_default" below.

### Expectation Criteria

The following methods may be used to create and refine expectations on
a mock object. See theFlexMock::Expectation for more details.

* <b>should_receive(<em>method_name</em>)</b>

  Declares that a message named _method_name_ will be sent to the mock
  object. Constraints on this expected message (called expectations)
  may be chained to the `should_receive` call.

* <b>should_receive(<em>method_name1</em>, <em>method_name2</em>, ...)</b>

  Define a number of expected messages that have the same constraints.

* <b>should_receive(<em>meth1</em> => <em>result1</em>, <em>meth2</em> => <em>result2</em>, ...)</b>

  Define a number of expected messages that have the same constrants, but
  return different values.

* <b>should_receive(...).explicitly</b>

  If a mock has a base class, use the `explicitly` modifier to
  override the restriction on method names imposed by the base class.
  The `explicitly` modifier must come immediately after the
  `should_receive` call and before any other expectation declarators.

  If a mock does not have a base class, this method has no effect.

* <b>should_expect { |<em>recorder</em>| ... }</b>

  Creates a mock recording object that will translate received method
  calls into mock expectations. The recorder is passed to a block
  supplied with the `should_expect` method. See examples
  below.

* <b>with(<em>arglist</em>)</b>

  Declares that this expectation matches messages that match the given
  argument list. The `===` operator is used on a argument by argument
  basis to determine matching. This means that most literal values
  match literally, class values match any instance of a class and
  regular expression match any matching string (after a `to_s`
  conversion). See argument validators (below) for details on argument
  validation options.

* <b>with_any_args</b>

  Declares that this expectation matches the message with any argument
  (default)

* <b>with_no_args</b>

  Declares that this expectation matches messages with no arguments

* <b>zero_or_more_times</b>

  Declares that the expected message is may be sent zero or more times
  (default, equivalent to `at_least.never`).

* <b>once</b>

  Declares that the expected message is only sent once. `at_least` /
  `at_most` modifiers are allowed.

* <b>twice</b>

  Declares that the expected message is only sent twice. `at_least` /
  `at_most` modifiers are allowed.

* <b>never</b>

  Declares that the expected message is never sent. `at_least` /
  `at_most` modifiers are allowed.

* <b>times(<em>n</em>)</b>

  Declares that the expected message is sent _n_ times. `at_least` /
  `at_most` modifiers are allowed.

* <b>at_least</b>

  Modifies the immediately following message count constraint so that
  it means the message is sent at least that number of times. E.g.
  `at_least.once` means the message is sent at least once during the
  test, but may be sent more often. Both `at_least` and `at_most` may
  be specified on the same expectation.

* <b>at_most</b>

  Similar to `at_least`, but puts an upper limit on the number of
  messages. Both `at_least` and `at_most` may be specified on the same
  expectation.

* <b>ordered</b>

  Declares that the expected message is ordered and is expected to be
  received in a certain position in a sequence of messages. The
  message should arrive after and previously declared ordered messages
  and prior to any following declared ordered messages. Unordered
  messages are ignored when considering the message order.

  Normally ordering is performed only against calls in the same mock
  object.  If the "globally" adjective is used, then ordering is
  performed against the other globally ordered method calls.

* <b>ordered(<em>group</em>)</b>

  Declare that the expected message belongs to an order group. Methods
  within an order group may be received in any order. Ordered messages
  outside the group must be received either before or after all of the
  grouped messages.

  For example, in the following, messages `flip` and `flop` may be
  received in any order (because they are in the same group), but must
  occur strictly after `start` but before `end`. The message
  `any_time` may be received at any time because it is not ordered.

```ruby
    m = flexmock()
    m.should_receive(:any_time)
    m.should_receive(:start).ordered
    m.should_receive(:flip).ordered(:flip_flop_group)
    m.should_receive(:flop).ordered(:flip_flop_group)
    m.should_receive(:end).ordered
```

  Normally ordering is performed only against calls in the same mock
  object.  If the "globally" adjective is used, then ordering is
  performed against the other globally ordered method calls.

* <b>globally.ordered</b>
* <b>globally.ordered(<em>group_name</em>)</b>

  When modified by the "globally" adjective, the mock call will be
  ordered against other globally ordered methods in any of the mock
  objects in the same container (i.e. same test).  All the options of
  the per-mock ordering are available in the globally ordered method
  calls.

* <b>by_default</b>

  Marks the expectation as a default.  Default expectations act as
  normal as long as there are no non-default expectations for the same
  method name.  As soon as a non-default expectation is defined, all
  default expectations for that method name are ignored.

  Default expectations allow you to setup a set of default behaviors
  for various methods in the setup of a test suite, and then override
  only the methods that need special handling in any given test.

### Expectation Actions

Action expectations are used to specify what the mock should _do_ when
the expectation is matched. The actions themselves do not take part in
determining whether a given expectation matches or not.

* <b>and_return(<em>value</em>)</b>

  Declares that the expected message will return the given value.

* <b>and_return(<em>value1</em>, <em>value2</em>, ...)</b>

  Declares that the expected message will return a series of values.
  Each invocation of the message will return the next value in the
  series. The last value will be repeatably returned if the number of
  matching calls exceeds the number of values.

* <b>and_return { |<em>args</em>, ...|  <em>code</em> ... }</b>

  Declares that the expected message will return the yielded value of
  the block. The block will receive all the arguments in the message.
  If the message was provided a block, it will be passed as the last
  parameter of the block's argument list.

* <b>returns( ... )</b>

  Alias for `and_return`.

* <b>and_return_undefined</b>

  Declares that the expected message will return a self-preserving
  undefined object (see FlexMock::Undefined for details).

* <b>returns_undefined</b>

  Alias for `and_returns_undefined`

* <b>and_raise(_exception_, _*args_)</b>

  Declares that the expected message will raise the specified
  exception. If `exception` is an exception class, then the raised
  exception will be constructed from the class with `new` given the
  supplied arguments. If `exception` is an instance of an exception
  class, then it will be raised directly.

* <b>raises( ... )</b>

  Alias for `and_raise`.

* <b>and_throw(<em>symbol</em>)</b>
* <b>and_throw(<em>symbol</em>, <em>value</em>)</b>

  Declares that the expected messsage will throw the specified symbol.
  If an optional value is included, then it will be the value returned
  from the corresponding catch statement.

* <b>throws( ... )</b>

  Alias for `and_throw`.

* <b>and_yield(<em>values</em>, ...)</b>

  Declares that the mocked method will receive a block, and the mock
  will call that block with the values given. Not providing a block
  will be an error. Providing more than one `and_yield` clause one a
  single expectation will mean that subsquent mock method calls will
  yield the values provided by the additional `and_yield` clause.

* <b>yields( ... )</b>

  Alias for `and_yield( ... )`.

* <b>pass_thru</b>
* <b>pass_thru { |<em>value</em>| .... }</b>

  Declares that the expected message will allow the method to be
  passed to the original method definition in the partial mock object.
  `pass_thru` is also allowed on regular mocks, but since there is no
  original method to be called, pass_thru will always return the
  undefined object.

  If a block is supplied to `pass_thru`, the value returned from the
  original method will be passed to the block and the value of the
  block will be returned. This allows you to mock methods on the
  returned value.

```ruby
    Dog.should_receive(:new).pass_thru { |dog|
      flexmock(dog, :wag => true)
    }
```

### Other Expectation Methods

* <b>mock</b>

  Expectation constraints always return the expectation so that the
  constraints can be chained. If you wish to do a one-liner and assign
  the mock to a variable, the `mock` method on an expectation will
  return the original mock object.

```ruby
    m = flexmock.should_receive(:hello).once.and_return("World").mock
```

  **NOTE:** _Using **mock** when specifying a Demeter mock
  chain will return the last mock of the chain, which might not be
  what you expect._

### Argument Validation

The values passed to the `with` declarator determine the criteria for
matching expectations. The first expectation found that matches the
arguments in a mock method call will be used to validate that mock
method call.

The following rules are used for argument matching:

* A `with` parameter that is a class object will match any
  actual argument that is an instance of that class.

  Examples:

```ruby
     with(Integer)     will match    f(3)
```

* A regular expression will match any actual argument that matches the
  regular expression. Non-string actual arguments are converted to
  strings via `to_s` before applying the regular
  expression.

  Examples:

```ruby
    with(/^src/)      will match    f("src_object")
    with(/^3\./)      will match    f(3.1415972)
```

* Most other objects will match based on equal values.

  Examples:

```ruby
      with(3)         will match    f(3)
      with("hello")   will match    f("hello")
```

* If you wish to override the default matching behavior and force
  matching by equality, you can use the FlexMock.eq convenience
  method. This is mostly used when you wish to match class objects,
  since the default matching behavior for class objects is to match
  instances, not themselves.

  Examples:

```ruby
      with(eq(Integer))             will match       f(Integer)
      with(eq(Integer))             will NOT match   f(3)
```

  **Note:** <em>If you do not use the FlexMock::TestCase Test Unit
  integration module, or the FlexMock::ArgumentTypes module, you will
  have to fully qualify the `eq` method. This is true of all the
  special argument matches (`eq`, `on`, `any`, `hsh` and
  `ducktype`).</em>

```ruby
      with(FlexMock.eq(Integer))
      with(FlexMock.on { code })
      with(FlexMock.any)
      with(FlexMock.hsh(:tag => 3))
      with(FlexMock.ducktype(:wag, :bark))
```

* If you wish to match a hash on _some_ of its values, the
  `FlexMock.hsh(...)` method will work. Only specify the hash values
  you are interested in, the others will be ignored.

```ruby
      with(hsh(:run => true))  will match    f(:run => true, :stop => false)
```

* If you wish to match any object that responds to a certain set of
  methods, use the `FlexMock.ducktype` method.


```ruby
      with(ducktype(:to_str))     will match   f("string")
      with(ducktype(:wag, :bark)) will match   f(dog)
                                  (assuming dog implements wag and bark)
```

* If you wish to match _anything_, then use the `FlexMock.any` method
  in the with argument list.

  Examples (assumes either the FlexMock::TestCase or FlexMock::ArgumentTypes
  mix-ins has been included):

```ruby
      with(any)             will match       f(3)
      with(any)             will match       f("hello")
      with(any)             will match       f(Integer)
      with(any)             will match       f(nil)
```

* If you wish to specify a complex matching criteria, use the
  `FlexMock.on(&block)` with the logic contained in the block.

  Examples (assumes `FlexMock::ArgumentTypes` has been included):

```ruby
      with(on { |arg| (arg % 2) == 0 } )
```

  will match any even integer.

* If you wish to match a method call where a block is given, add
  `Proc` as the last argument to `with`.

  Example:

```ruby
      m.should_receive(:foo).with(Integer,Proc).and_return(:got_block)
      m.should_receive(:foo).with(Integer).and_return(:no_block)
```

  will cause the mock to return the following:

```ruby
     m.foo(1) { } => returns :got_block
     m.foo(1)     => returns :no_block
```

### Creating Partial Mocks

Sometimes it is useful to mock the behavior of one or two methods in
an existing object without changing the behavior of the rest of the
object. If you pass a real object to the `flexmock` method, it will
allow you to use that real object in your test and will just mock out
the one or two methods that you specify.

For example, suppose that a Dog object uses a Woofer object to bark.
The code for Dog looks like this (we will leave the code for Woofer to
your imagination):

```ruby
  class Dog
    def initialize
      @woofer = Woofer.new
    end
    def bark
      @woofer.woof
    end
    def wag
      :happy
    end
  end
```

Now we want to test Dog, but using a real Woofer object in the test is
a real pain (why? ... well because Woofer plays a sound file of a dog
barking, and that's really annoying during testing).

So, how can we create a Dog object with mocked Woofer? All we need to
do is allow FlexMock to replace the `bark` method.

Here's the test code:

```ruby
  class TestDogBarking < Test::Unit::TestCase
    include FlexMock::TestCase

    # Setup the tests by mocking the +new+ method of
    # Woofer and return a mock woofer.
    def setup
      @dog = Dog.new
      flexmock(@dog, :bark => :grrr)
    end

    def test_dog
      assert_equal :grrr, @dog.bark   # Mocked Method
      assert_equal :happy, @dog.wag    # Normal Method
    end
  end
```

The nice thing about this technique is that after the test is over,
the mocked out methods are returned to their normal state. Outside the
test everything is back to normal.

**NOTE:** <em>In previous versions of FlexMock, partial mocking was
called "stubs" and the `flexstub` method was used to create the
partial mocks. Although partial mocks were often used as stubs, the
terminology was not quite correct. The current version of FlexMock
uses the `flexmock` method to create both regular stubs and partial
stubs. A version of the `flexstub` method is included for backwards
compatibility. See Martin Fowler's article
[_Mocks Aren't Stubs_](http://www.martinfowler.com/articles/mocksArentStubs.html
"Mocks Aren't Stubs") for a better understanding of the difference
between mocks and stubs.</em>

This partial mocking technique was inspired by the `Stuba` library in
the `Mocha` project.

### Spies

FlexMock supports spy-like mocks as well as the traditional mocks.

```ruby
  # In Test::Unit / MiniTest
  class TestDogBarking < Test::Unit::TestCase
    def test_dog
      dog = flexmock(:on, Dog)
      dog.bark("loud")
      assert_spy_called dog, :bark, "loud"
    end
  end

  # In RSpec
  describe Dog do
    let(:dog) { flexmock(:on, Dog) }
    it "barks loudly" do
      dog.bark("loud")
      dog.should have_received(:bark).with("loud")
    end
  end
```

Since spies are verified after the code under test is run, they fit
very nicely with the Given/When/Then technique of specification. Here
is the above RSpec example using the rspec-given gem:

```ruby
  require 'rspec/given'

  describe Dog do
    Given(:dog) { flexmock(:on, Dog) }

    context "when barking loudly" do
      When { dog.bark("loud") }
      Then { dog.should have_received(:bark).with("loud") }
    end
  end
```

*NOTE:* <em>You can only spy on methods that are mocked or stubbed.
That's not a problem with regular mocks, but normal methods on partial
objects will not be recorded.</em>

You can get around this limitation by stubbing the method in question
on the normal mock, and then specifying `pass_thru`. Assuming `:bark`
is a normal method on a Dog object, then the following allows for
spying on `:bark`.

```ruby
   dog = Dog.new
   flexmock(dog).should_receive(:bark).pass_thru
   # ...
   dog.should have_received(:bark)
```

#### Asserting Spy Methods are Called (Test::Unit / MiniTest)

FlexMock provied a custom assertion method for use with Test::Unit and
MiniTest for asserting that mocked methods are actually called.

* <b>assert_spy_called <em>mock</em>, <em>options_hash</em>, <em>method_name</em>, <em>args...</em></b>

  This will assert that the method called _method_name_ has been
  called at least once on the given mock object. If arguments are
  given, then the method must be called with actual argument that
  match the given argument matchers.

  All the argument matchers defined in the "Argument Validation"
  section above are allowed in the `assert_spy_called`
  method.

  The `options` hash is optional. If omitted, all options will have
  their default values. See below for spy option definitions.

* <b>assert_spy_not_called <em>mock</em>, <em>options_hash</em>, <em>method_name</em>, <em>args...</em></b>

  Same as `assert_spy_called`, except with the sense of the
  test reversed.

*Spy Options*

* <b>times: <em>n</em></b>

  Specify the number of times a matching method should have been
  invoked. `nil` (or omitted) means any number of times.

* <b>with_block: <em>true/false/nil</em>

  Is a block required on the invocation? `true` means the method must
  be invoked with a block. `false` means the method must have been
  invoked without a block. `nil` means that the presence of a block
  does not matter. Default is `nil`.

* <b>and: [<em>proc1</em>, <em>proc2...</em>]</b>

  Additional validations to be run on each matching method call. The
  list of arguments for each call is passed to the procs. This allows
  additional validations on supplied arguments. Default is no
  additional validations.

* <b>on: <em>n</em>

  Only apply the additional validations on the <em>n</em>'th
  invocation of the matching method. Default is apply additional
  validations to all invocations.

*Examples:*

```ruby
    dog = flexmock(:on, Dog)

    dog.wag(:tail)
    dog.wag(:head)
    dog.bark(5)
    dog.bark(6)

    assert_spy_called dog, :wag, :tail
    assert_spy_called dog, :wag, :head
    assert_spy_called dog, {times: 2}, :wag

    assert_spy_not_called dog, :bark
    assert_spy_not_called dog, {times: 3}, :wag

    is_even = proc { |n| assert_equal 0, n%2 }
    assert_spy_called dog, { and: is_even, on: 2 }, :bark, Integer
```

#### RSpec Matcher for Spying

FlexMock also provides an RSpec matcher that can be used to specify
spy behavior.

* <b>mock.should have_received(<em>method_name</em>).<em>modifier1</em>.<em>modifier2</em>...</b>

  Specifies that the method named _method_name_ should have
  been received by the mock object with the given arguments.

  Just like `should_receive`, `have_received` will accept a number of
  modifiers that modify its behavior.

*Modifiers for `have_received`*

* <b>with(<em>args</em>)

  If a `with` modifier is given, only messages with matching arguments
  are considered. _args_ can be any of the argument matches mentioned
  in the "Argument Validation" section above. If `with` is not given,
  then the arguments are not considered when finding matching calls.

* <b>times(<em>n</em>)</b>

  If a `times` modifier is given, then there must be exactly `n` calls
  for that method name on the mock. If the `times` clause is not
  given, then there must be at least one call matching the method name
  (and arguments if they are considered).

  * `never` is an alias for `times(0)`,
  * `once` is an alias for `times(1)`, and
  * `twice` is an alias for `times(2)`.

* <b>and { |args| <em>code</em> }</b>

  If an `and` modifier is given, then the supplied block will be run as
  additional validations on any matching call.  Arguments to the
  matching call will be supplied to the block. If multiple `and`
  modifiers are given, all the blocks will be run.  The additional
  validations are run on all the matching calls unless an `on`
  modifier is supplied.

* <b>on(<em>n</em>)</b>

  If an `on` modifier is given, then the additional validations
  supplied by `and` will only be run on the <em>n</em>'th invocation
  of the matching method.

*Examples:*

```ruby
    dog = flexmock(:on, Dog)

    dog.wag(:tail)
    dog.wag(:head)

    dog.should have_received(:wag).with(:tail)
    dog.should have_received(:wag).with(:head)
    dog.should have_received(:wag).twice

    dog.should_not have_received(:bark)
    dog.should_not have_received(:wag).times(3)

    dog.bark(3)
    dog.bark(6)
    dog.should have_received(:bark).with(Integer).and { |arg|
      (arg % 3).should == 0
    }
    dog.should have_received(:bark).with(Integer).and { |arg|
      arg.should == 6
    }.on(2)

```

### Mocking Class Object

In the previous example we mocked out the `bark` method of a Dog
object to avoid invoking the Woofer object. Perhaps a better technique
would be to mock the Woofer object directly. But Dog uses Woofer
explicitly so we cannot just pass in a mock object for Dog to use.

But wait, we can add mock behavior to any existing object, and classes
are objects in Ruby. So why don't we just mock out the Woofer class
object to return mocks for us.

```ruby
  class TestDogBarking < Test::Unit::TestCase
    include FlexMock::TestCase

    # Setup the tests by mocking the `new` method of
    # Woofer and return a mock woofer.
    def setup
      flexmock(Woofer).should_receive(:new).
         and_return(flexmock(:woof => :grrr))
      @dog = Dog.new
    end

    def test_dog
      assert_equal :grrrr, @dog.bark  # Calls woof on mock object
                                      # returned by Woofer.new
    end
  end
```

### Mocking Behavior in All Instances Created by a Class Object

Sometimes returning a single mock object is not enough. Occasionally you want
to mock _every_ instance object created by a class. FlexMock makes this
very easy.

```ruby
  class TestDogBarking < Test::Unit::TestCase
    include FlexMock::TestCase

    # Setup the tests by mocking Woofer to always
    # return partial mocks.
    def setup
      flexmock(Woofer).new_instances.should_receive(:woof => :grrr)
    end

    def test_dog
      assert_equal :grrrr, Dog.new.bark  # All dog objects
      assert_equal :grrrr, Dog.new.bark  # are mocked.
    end
  end
```

Note that FlexMock adds the mock expectations after the original `new`
method has completed. If the original version of `new` yields the
newly created instance to a block, that block will get an non-mocked
version of the object.

Note that `new_instances` will accept a block if you wish to mock
several methods at the same time. E.g.

```ruby
      flexmock(Woofer).new_instances do |m|
        m.should_receive(:woof).twice.and_return(:grrr)
        m.should_receive(:wag).at_least.once.and_return(:happy)
      end
```

### Default Expectations on Mocks

Sometimes you want to setup a bunch of default expectations that are
pretty much for a number of different tests.  Then in the individual
tests, you would like to override the default behavior on just that
one method you are testing at the moment.  You can do that by using
the `by_default` modifier.

In your test setup you might have:

```ruby
  def setup
    @mock_dog = flexmock("Fido")
    @mock_dog.should_receive(:tail => :a_tail, :bark => "woof").by_default
  end
```

The behaviors for `:tail` and `:bark` are good for most of the tests,
but perhaps you wish to verify that `:bark` is called exactly once in
a given test. Since :bark by default has no count expectations, you
can override the default in the given test.

```ruby
  def test_something_where_bark_must_be_called_once
    @mock_dog.should_receive(:bark => "woof").once

    # At this point, the default for :bark is ignored,
    # and the "woof" value will be returned.

    # However, the default for :tail (which returns :a_tail)
    # is still active.
  end
```

By setting defaults, your individual tests don't have to concern
themselves with details of all the default setup.  But the details of
the overrides are right there in the body of the test.

### Mocking Law of Demeter Violations

The Law of Demeter says that you should only invoke methods on objects
to which you have a direct connection, e.g. parameters, instance
variables, and local variables.  You can usually detect Law of Demeter
violations by the excessive number of periods in an expression.  For
example:

```ruby
     car.chassis.axle.universal_joint.cog.turn
```

The Law of Demeter has a very big impact on mocking.  If you need to
mock the "turn" method on "cog", you first have to mock chassis, axle,
and universal_joint.

```ruby
    # Manually mocking a Law of Demeter violation
    cog = flexmock("cog")
    cog.should_receive(:turn).once.and_return(:ok)
    joint = flexmock("gear", :cog => cog)
    axle = flexmock("axle", :universal_joint => joint)
    chassis = flexmock("chassis", :axle => axle)
    car = flexmock("car", :chassis => chassis)
```

Yuck!

The best course of action is to avoid Law of Demeter violations.  Then
your mocking exploits will be very simple.  However, sometimes you
have to deal with code that already has a Demeter chain of method
calls.  So for those cases where you can't avoid it, FlexMock will
allow you to easily mock Demeter method chains.

Here's an example of Demeter chain mocking:

```ruby
    # Demeter chain mocking using the short form.
    car = flexmock("car")
    car.should_receive( "chassis.axle.universal_joint.cog.turn" => :ok).once
```

You can also use the long form:

```ruby
    # Demeter chain mocking using the long form.
    car = flexmock("car")
    car.should_receive("chassis.axle.universal_joint.cog.turn").once.
      and_return(:ok)
```

That's it. Anywhere FlexMock accepts a method name for mocking, you
can use a demeter chain and FlexMock will attempt to do the right
thing.

But beware, there are a few limitations.

The all the methods in the chain, except for the last one, will mocked
to return a mock object. That mock object, in turn, will be mocked so
as to respond to the next method in the chain, returning the following
mock. And so on. If you try to manually mock out any of the chained
methods, you could easily interfer with the mocking specified by the
Demeter chain. FlexMock will attempt to catch problems when it can,
but there are certainly scenarios where it cannot detect the problem
beforehand.

## Examples

Refer to the following documents for examples of using FlexMock:

* [RSpec Examples](https://github.com/jimweirich/flexmock/blob/master/doc/examples/rspec_examples_spec.rb)
* [Test::Unit / MiniTest Examples](https://github.com/jimweirich/flexmock/blob/master/doc/examples/test_unit_examples_test.rb)

## License

Copyright 2003-2013 by Jim Weirich (jim.weirich@gmail.com).
All rights reserved.

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work as long as the
above copyright notice is included.

# Other stuff

* **Author** -- Jim Weirich <jim.weirich@gmail.com>
* **Requires** -- Ruby 1.9.2 or later (also works with Ruby 1.8.7)

## See Also

If you like the spy capability of FlexMock, you should check out the
[rspec-given gem](http://rubygems.org/gems/rspec-given) that allows you
to use Given/When/Then statements in you specifications.

## Warranty

This software is provided "as is" and without any express or implied
warranties, including, without limitation, the implied warranties of
merchantibility and fitness for a particular purpose.
