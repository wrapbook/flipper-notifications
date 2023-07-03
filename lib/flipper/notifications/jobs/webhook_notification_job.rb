# frozen_string_literal: true

require "active_job"
require "flipper/notifications/webhooks/errors"

module Flipper
  module Notifications
    class WebhookNotificationJob < ActiveJob::Base

      sidekiq_options(retry: 0) if respond_to?(:sidekiq_options)

      # TODO: Pull queue from configuration?
      # queue_as :low

      retry_on Webhooks::NetworkError,
               Webhooks::ServerError,
               attempts: 3,
               wait:     :exponentially_longer

      def perform(webhook:, **webhook_args)
        webhook.notify(**webhook_args)
      end

    end
  end
end
