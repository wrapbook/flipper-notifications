# frozen_string_literal: true

require "active_job"
require_relative "webhook"

module Flipper
  module Notifications
    module Webhooks
      class Serializer < ActiveJob::Serializers::ObjectSerializer
        def serialize?(argument)
          argument.is_a?(Webhook)
        end

        def serialize(webhook)
          super(
            "class"      => webhook.class.name,
            "attributes" => webhook.serialized_attributes
          )
        end

        def deserialize(hash)
          hash["class"].constantize.new(**hash["attributes"].deep_symbolize_keys)
        end
      end
    end
  end
end
