# frozen_string_literal: true

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Memory.new }
end

Flipper::Notifications.configure do |config|
  config.enabled = !ENV.key?("FLIPPER_NOTIFICATIONS_DISABLED")

#   config.webhooks = [
#     FlipperNotifications::Webhooks::Slack.new(
#       url: ENV.fetch("SLACK_WEBHOOK_URL")
#     )
#   ]

#   config.scheduler = ->(webhook:, event:) do
#     WebhookNotificationJob.perform_later(webhook: webhook, event: event)
#   end
end
