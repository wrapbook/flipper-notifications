# frozen_string_literal: true

require_relative "event_serializer"
require_relative "jobs/webhook_notification_job"
require_relative "webhooks/serializer"

module Flipper
  module Notifications
    class Railtie < Rails::Railtie
      initializer "flipper-notifications.configure_rails_initialization" do
        Flipper::Notifications.configure do |config|
          config.scheduler = ->(webhook:, event:) do
            WebhookNotificationJob.perform_later(webhook: webhook, event: event)
          end
        end

        Flipper::Notifications.subscribe!
      end

      config.active_job.custom_serializers += [
        EventSerializer,
        Webhooks::Serializer
      ]
    end
  end
end
