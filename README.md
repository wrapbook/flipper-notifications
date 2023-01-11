# Flipper::Notifications

Rails-compatible Slack notifications when [Flipper](https://github.com/jnunemaker/flipper)
flags are updated.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flipper-notifications'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flipper-notifications

## Dependencies

* Ruby 3
* ActiveSupport 7

This gem is designed to work within a Rails app.  At the very least, you will
need `activesupport` since that library drives instrumentation from Flipper
itself.

## Usage

After you initialize `Flipper`, you can also configure `Flipper::Notifications`.

```ruby
# config/initializers/flipper.rb

Flipper.configure do |config|
  config.adapter { ... }
end

Flipper::Notifications.configure do |config|
  # You have to enable notifications; you probably only want notifications enabled in production.
  config.enabled = true

  slack_webhook = Flipper::Notifications::Webhooks::Slack.new(url: ENV.fetch("SLACK_WEBHOOK_URL"))

  config.notifiers = [
    Flipper::Notifications::Notifiers::WebhookNotifier.new(webhook: webhook)
  ]
end
```

### Implementing Your Own Webhooks

WIP

### Implementing Your Own Notifiers

A `Notifier` is any object that responds to a `call` method with a keyword
argument named `event`.  You can use a `lambda` as your notifier if you prefer.
Using a `lambda` can come in handy if you want to provide additional context
to your notifications.

```ruby
Flipper::Notifications.configure do |config|
  webhook = Flipper::Notifications::Webhooks::Slack.new(url: ENV.fetch("SLACK_WEBHOOK_URL"))

  notifier = ->(event:) do
    context = "#{Rails.env} (changed by: #{Current.user.email})"
    WebhookNotificationJob.perform_later(webhook: webhook, event: event, context_markdown: context)
  end

  config.notifiers = [notifier]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Releasing

After merging in the new functionality to the main branch:

```
git checkout main
git pull --prune
bundle exec rake version:bump:<major, minor, or patch>
bundle exec rubocop -a
git commit -a --amend
bundle exec rake release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/wrapbook/flipper-notifications. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Flipper::Notifications project’s codebases,
issue trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/[USERNAME]/flipper-notifications/blob/master/CODE_OF_CONDUCT.md).
