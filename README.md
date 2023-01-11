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

This gem is designed to work within a Rails app. At the very least, you will
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

This gem provides an implementation to send notifications to Slack via an
[incoming webhook](https://api.slack.com/messaging/webhooks).
If you want to integrate with a service other than Slack, you may wish to
implement your own `Webhook` by following the pattern established by this gem.
If you implement your own `Webhook`, and you have a Rails app that uses `ActiveJob`,
you can use the `Flipper::Notifications::WebhookNotificationJob` provided by this
gem to send webhook requests asynchronously. The job also includes a sensible
retry strategy just in case the internet or your notification service is having a bad day.

Your `Webhook` can start by inheriting from `Flipper::Notifications::Webhook`.
The `Webhook` base class defines an initializer that takes one keyword argument, `url`.
You only need to implement an instance method named `notify`. The `notify` method
should take keyword arguments.  Within the `notify` method you have access to
[HTTParty](https://github.com/jnunemaker/httparty) methods for sending requests.
In the end, your `Webhook` might look something like this:

```ruby
class MyWebhook < Flipper::Notifications::Webhook

  def notify(foo:, bar:)
    webhook_api_errors do
      self.class.post(@url, body: { foo: foo, bar: bar }.to_json)
    end
  end

end
```

The `webhook_api_errors` helper wraps common API errors as specific `Flipper::Notifications`
error types:

* `Flipper::Notifications::ClientError` - 4XX HTTP responses
* `Flipper::Notifications::ServerError` - 5XX HTTP responses
* `Flipper::Notifications::NetworkError` - Timeouts

### Implementing Your Own Notifiers

You may want to implement notifications without using the `Webhook` pattern
described above. If so, all you have to do is implement your own `Notifier`.
A `Notifier` is any object that responds to a `call` method with a keyword
argument named `event`. You can use a `lambda` as your notifier if you prefer.
Using a `lambda` can come in handy if you want to provide additional context
to your notifications.

```ruby
Flipper::Notifications.configure do |config|
  webhook = Flipper::Notifications::Webhooks::Slack.new(url: ENV.fetch("SLACK_WEBHOOK_URL"))

  notifier = ->(event:) do
    context = "#{Rails.env} (changed by: #{Current.user.email})"
    Flipper::Notifications::WebhookNotificationJob.perform_later(webhook: webhook, event: event, context_markdown: context)
  end

  config.notifiers = [notifier]
end
```

The `event` object will be a `Flipper::Notifications::FeatureEvent`.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing

After merging in the new functionality to the main branch, you can run the following
to push a new version of the gem to [rubygems.org](https://rubygems.org):

```
git checkout main
git pull
bundle exec rake version:bump:<major, minor, or patch>
bundle exec rubocop -a
git commit -a --amend --no-edit
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
