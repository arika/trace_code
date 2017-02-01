# TraceCode

Code tracing library for single method call, or tiny coverage tool

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trace_code'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trace_code

## Usage

Block:

```ruby
TraceCode.start(FooClass, BarClass, ..., color: :dark) do
  # method call
end

Method:

```ruby
TraceCode.start(...)
# method call
TraceCode.finish
```
Methods:

* `TraceCode.start` - start trace
* `TraceCode.finish` - finish trace

`TraceCode.start` Options:

* classes/modules - trace targets
* `:color` - `:dark`, `:light`, `false`, `true`(=`:dark`); default `true`
* `:output` - IO object; default `$stdout`

### Example

Code:

```ruby
class FoosControllerTest < ActionController::TestCase
  sub_test_case 'TraceCode sample' do
    test 'trace the index action' do
      TraceCode.start(FoosController) do
        get :index
      end
      assert_response :success
    end
  end
end
```

Output:

```
$ bin/rails test test/controllers/foos_controller_test.rb
Loaded suite rake
Started
/.../app/controllers/foos_controller.rb:
    1: class FoosController < ApplicationController
    2:         :
               :
        (evaluated lines are highlighted)
               :
  254:         :
  255: end
.

Finished in 1.404759 seconds.
------------------------------------------------------------------------------
1 tests, 1 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
------------------------------------------------------------------------------
0.32 tests/s, 3.13 assertions/s
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/trace_code.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
