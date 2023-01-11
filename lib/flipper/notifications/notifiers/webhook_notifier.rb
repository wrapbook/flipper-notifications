# frozen_string_literal: true

require "flipper/notifications/jobs/webhook_notification_job"

module Flipper
  module Notifications
    module Notifiers
      class WebhookNotifier

        def initialize(webhook:)
          @webhook = webhook
        end

        def call(event:)
          WebhookNotificationJob.perform_later(webhook: @webhook, event: event)
        end

      end
    end
  end
end
