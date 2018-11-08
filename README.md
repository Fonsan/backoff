# Backoff

Add exponential full jitter backoff to any object by proxy

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'backoff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backoff

## Usage

```ruby
require 'backoff'
require 'logger'
logger = Logger.new($stderr)
class Foo
  class MyError < StandardError; end
  class MyErrorTwo < StandardError; end

  def initialize
    @i = 0
  end

  def bar
    @i += 1
    raise MyError if @i < 2
    raise MyErrorTwo if @i < 4
    true
  end
end
# The second argument may be a exception class or a list of exception classes
foo_with_backoff = Backoff.wrap(Foo.new, [Foo::MyError, Foo::MyErrorTwo], logger, initial_backoff: 1, multiplier: 2)
p foo_with_backoff.bar
# E, [2018-11-08T10:17:16.199572 #33699] ERROR -- : Got Foo::MyError, sleeping 0.5672605987514756
# I, [2018-11-08T10:17:17.204727 #33699]  INFO -- : Woke up after Foo::MyError retrying again
# E, [2018-11-08T10:17:17.204903 #33699] ERROR -- : Got Foo::MyErrorTwo, sleeping 1.6799593245880358
# I, [2018-11-08T10:17:19.205967 #33699]  INFO -- : Woke up after Foo::MyErrorTwo retrying again
# E, [2018-11-08T10:17:19.206074 #33699] ERROR -- : Got Foo::MyErrorTwo, sleeping 3.732148747396218
# I, [2018-11-08T10:17:23.206237 #33699]  INFO -- : Woke up after Foo::MyErrorTwo retrying again
# => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fonsan/backoff. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Backoff project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Fonsan/backoff/blob/master/CODE_OF_CONDUCT.md).
