# frozen_string_literal: true

require "active_job"
require "flipper/notifications/webhooks/errors"

module Flipper
  module Notifications
    class WebhookNotificationJob < ActiveJob::Base

      def self.disable_sidekiq_retries
        sidekiq_options(retry: 0) if respond_to?(:sidekiq_options)
      end

      # TODO: Pull queue from configuration?
      # queue_as :low

      retry_on Webhooks::NetworkError,
               Webhooks::ServerError,
               attempts: 3,
               wait:     ActiveJob.version < Gem::Version.new("7.1") ? :exponentially_longer : :polynomially_longer

      def perform(webhook:, **webhook_args)
        webhook.notify(**webhook_args)
      end

    end
  end
end
