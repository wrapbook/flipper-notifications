# frozen_string_literal: true

require "flipper/notifications/event_serializer"
require "flipper/notifications/webhooks/serializer"
require "flipper/notifications/notifiers/webhook_notifier"

module Flipper
  module Notifications
    class Railtie < Rails::Railtie

      initializer "flipper-notifications.configure_rails_initialization" do
        Flipper::Notifications.subscribe!
      end

      config.to_prepare do
        ActiveJob::Serializers.add_serializers(
          EventSerializer,
          Webhooks::Serializer
        )
      end

      config.after_initialize do
        WebhookNotificationJob.disable_sidekiq_retries
      end

    end
  end
end
