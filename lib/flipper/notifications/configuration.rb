# frozen_string_literal: true

module Flipper
  module Notifications
    class Configuration

      def initialize
        @enabled   = false
        @notifiers = []
        @webhook_character_limit = nil
      end

      attr_accessor :enabled, :notifiers, :webhook_character_limit

      def enabled?
        @enabled
      end

    end
  end
end
