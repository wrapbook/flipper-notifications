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
      configuration.notifiers.each { |notifier| notifier.call(event: event) }
    end

    def subscribe!
      @subscriber = ActiveSupport::Notifications.subscribe(
        Flipper::Feature::InstrumentationName,
        FeaturesSubscriber.new
      )
    end

    def unsubscribe!
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end

    # WARNING: this implementation is not thread-safe
    def disabled
      previous_value = configuration.enabled
      configuration.enabled = false
      yield
    ensure
      configuration.enabled = previous_value
    end
  end
end

require_relative "notifications/railtie" if defined?(Rails::Railtie)
