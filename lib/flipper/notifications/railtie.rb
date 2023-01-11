# frozen_string_literal: true

require "flipper/notifications/event_serializer"
require "flipper/notifications/webhooks/serializer"
require "flipper/notifications/notifiers/webhook_notifier"

module Flipper
  module Notifications
    class Railtie < Rails::Railtie

      initializer "flipper-notifications.configure_rails_initialization" do
        Flipper::Notifications.subscribe!

        config.active_job.custom_serializers += [
          EventSerializer,
          Webhooks::Serializer
        ]
      end

    end
  end
end
