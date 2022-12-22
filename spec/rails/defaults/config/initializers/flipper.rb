# frozen_string_literal: true

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Memory.new }
end

Flipper::Notifications.configure do |config|
  config.enabled = !ENV.key?("FLIPPER_NOTIFICATIONS_DISABLED")

  config.webhooks = [
    Flipper::Notifications::Webhooks::Slack.new(url: ENV.fetch("SLACK_WEBHOOK_URL"))
  ]
end
