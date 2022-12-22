# frozen_string_literal: true

module Flipper
  module Notifications
    class Configuration
      def initialize
        @enabled   = false
        @scheduler = ->(webhook:, event:) {}
        @webhooks  = []
      end

      attr_accessor :enabled, :scheduler, :webhooks

      def enabled?
        @enabled
      end
    end
  end
end
