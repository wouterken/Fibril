# Fibril

Fibril is a pure Ruby library that allows you to use cooperative multitasking inside your Ruby code. It is a similar concept to the event loop in JavaScript, but makes use of context switching through Fibers to prevent the need for callback functions or promises.

Traditionally you might approach concurrency in Ruby through the use of threads and concurrency primitives to synchronise critical sections of your code. Fibril takes an alternative approach where instead everything is synchronous/safe unless explicitly told otherwise.

You can use Fibril to yield from a flow of execution while waiting on an asychrouous call and fibril will schedule the same flow to resume as soon the asynchronous call is complete. All without the need for callbacks.

You can be explicit in how you weave your fibrils together to ensure the order in which your multiple tasks execute is deterministic.

## Why is it useful?

You may be interested in Fibril if:
* Your code has many fast operations that are often blocked by slow operations
* You want to use two or more Ruby libraries which require a blocking IO loop together.
* You have multiple IO operations that you wish to execute in parallel while ensuring the rest of your code executes synchronously
* You want to manipulate multiple streams of data in parallel without having to worry about synchronisation across threads.

In scenarios where many IO bound operations are the performance bottleneck of your application Fibril is likely to provide performance benefits. In other scenarios performance should be comparable to that using threads or executing all tasks synchronously.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fibril'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fibril

## Usage

Read the wiki [here]() to learn how to use Fibril.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fibril.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

