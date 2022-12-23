# frozen_string_literal: true

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Memory.new }
end

Flipper::Notifications.configure do |config|
  config.enabled = !ENV.key?("FLIPPER_NOTIFICATIONS_DISABLED")

  slack_webhook = Flipper::Notifications::Webhooks::Slack.new(url: ENV.fetch("SLACK_WEBHOOK_URL"))

  config.notifiers = [
    Flipper::Notifications::Notifiers::WebhookNotifier.new(webhook: slack_webhook)
  ]
end
