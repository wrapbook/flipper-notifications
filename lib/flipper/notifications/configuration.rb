# frozen_string_literal: true

module Flipper
  module Notifications
    class Configuration

      def initialize
        @enabled   = false
        @notifiers = []
        @webhook_character_limit = nil
        @flipper = nil
      end

      attr_accessor :enabled, :notifiers, :webhook_character_limit
      attr_writer :flipper

      def enabled?
        @enabled
      end

      # The Flipper instance used to READ feature state when rendering a
      # notification. Defaults to the global `Flipper`.
      #
      # Notifications are rendered in a background job, which may run in a
      # different process from the one that changed the feature. If your Flipper
      # adapter is fronted by a per-process cache (e.g. an in-memory
      # ActiveSupportCacheStore), the reading process can hold a stale value and
      # the message reports the wrong state. Point this at a cache-free instance
      # backed by your source of truth to always render the real value, e.g.:
      #
      #   config.flipper = Flipper.new(Flipper::Adapters::ActiveRecord.new)
      def flipper
        @flipper || Flipper
      end

    end
  end
end
