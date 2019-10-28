# Dry::Lifecycle

A StateMachine implementation designed to fit in with the [dry-rb][http://dry-rb.org/] family of gems. Provides a DSL for specifying the allowed state values that an
object can have, as well as which stats are allowed _exits_ from the current state. Exit state transitions can be guarded.

You define your Lifecycle, and then send your object (which must have a :state attribute), and the new state you want the object to be in, to the #call method of your Lifecycle instance. If the transition succeeds, Lifecycle returns a dry-monads `Success()` instance, wrapping the object in its new state. Otherwise, it returns a `Failure()` instance, wrapping either the exception that was raised, or the String messages of the failing guard classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-lifecycle', git: 'https://github.com/hashrabbit/dry-lifecycle.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dry-lifecycle

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brianvh/dry-lifecycle. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dry::Lifecycle project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/brianvh/dry-lifecycle/blob/master/CODE_OF_CONDUCT.md).
