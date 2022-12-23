# frozen_string_literal: true

module Flipper
  module Notifications
    class Configuration
      def initialize
        @enabled   = false
        @notifiers = []
      end

      attr_accessor :enabled, :notifiers

      def enabled?
        @enabled
      end
    end
  end
end
