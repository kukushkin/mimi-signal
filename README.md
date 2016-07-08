# Mimi::Signal

Asynchronous processing of trapped signals, solving the limitations of the
[Ruby trap context](https://www.google.de/search?q=ruby+trap+context).

#### Problem:
```ruby
logger = Logger.new(STDOUT)

trap('INT') do
  logger.warn 'Interrupted' # => (ThreadError) can't be called from trap context
  # shutdown gracefully ... never executed :(
end
```

#### Solution:
```ruby
require 'mimi/signal'

logger = Logger.new(STDOUT)

Mimi::Signal.trap('INT') do
  logger.warn 'Interrupted' # works!
  # shutdown gracefully ...
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mimi-signal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mimi-signal

## Usage

Setting up a signal handler:
```ruby
require 'mimi/signal'

Mimi::Signal.trap('INT') do
  # do my stuff
end
```

Setting up multiple signal handlers:
```ruby
require 'mimi/signal'

Mimi::Signal.trap('INT', 'TERM') do
  # this will be invoked on SIGINT or SIGTERM
end

Mimi::Signal.trap('INT') do
  # this will be invoked on SIGINT in addition to the handler above
end
```

Stopping the signal handlers, untrapping the previously trapped signals:
```ruby
require 'mimi/signal'

Mimi::Signal.trap('TERM') do
  # something
end

Mimi::Signal.trap('INT') do
  # something
end

Mimi::Signal.stop # untraps INT and TERM, reverting the handlers to the original handlers
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kukushkin/mimi-signal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

