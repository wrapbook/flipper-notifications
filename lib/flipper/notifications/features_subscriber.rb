# frozen_string_literal: true

require "active_support/notifications"
require_relative "feature_event"

module Flipper
  module Notifications
    class FeaturesSubscriber

      def call(*args)
        return unless enabled?

        event = FeatureEvent.from_active_support(event: ActiveSupport::Notifications::Event.new(*args))
        Flipper::Notifications.notify(event: event) if event.noteworthy?
      end

      private

      def enabled?
        Flipper::Notifications.configuration.enabled?
      end

    end
  end
end
