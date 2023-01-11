# frozen_string_literal: true

require "active_job"
require_relative "feature_event"

module Flipper
  module Notifications
    class EventSerializer < ActiveJob::Serializers::ObjectSerializer

      def serialize?(argument)
        argument.is_a?(FeatureEvent)
      end

      def serialize(event)
        super(
          feature_name: event.feature.name,
          operation:    event.operation
        )
      end

      def deserialize(hash)
        FeatureEvent.new(**hash.symbolize_keys.slice(:feature_name, :operation))
      end

    end
  end
end
