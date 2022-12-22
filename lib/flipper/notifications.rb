# frozen_string_literal: true

require "active_support/notifications"
require "flipper/notifications/version"

require_relative "notifications/configuration"
require_relative "notifications/feature_event"
require_relative "notifications/features_subscriber"
require_relative "notifications/webhooks"

module Flipper
  module Notifications
    class Error < StandardError; end

    module_function

    @subscriber = nil

    def configure
      yield configuration if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def notify(event:)
      configuration.webhooks.each do |webhook|
        configuration.scheduler.call(webhook: webhook, event: event)
      end
    end

    def subscribe!
      @subscriber = ActiveSupport::Notifications.subscribe(Flipper::Feature::InstrumentationName, FeaturesSubscriber.new)
    end

    def unsubscribe!
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end
  end
end

require_relative "notifications/railtie" if defined?(Rails::Railtie)
