# frozen_string_literal: true

module Flipper
  module Notifications
    class FeatureEvent

      NOTEWORTHY_OPERATIONS = %w[
        add
        enable
        disable
        clear
        remove
      ].freeze

      def self.from_active_support(event:)
        new(
          feature_name: event.payload[:feature_name],
          operation:    event.payload[:operation]
        )
      end

      def initialize(feature_name:, operation:)
        @feature   = Flipper.feature(feature_name)
        @operation = operation.to_s
      end

      attr_reader :feature, :operation

      def summary_markdown
        msg = String.new("Feature *#{feature.name}* was #{action_taken}.")

        if include_state?
          msg << " The feature is now *fully enabled.*" if feature.on?
          msg << " The feature is now *fully disabled.*" if feature.off?
        end

        msg
      end

      def feature_enabled_settings_markdown
        return "" unless feature.conditional?

        [].tap do |settings|
          settings << "The feature is now enabled for:" if feature.conditional?

          settings << "- Groups: #{to_sentence(feature.enabled_groups.map(&:name).sort)}" if feature.enabled_groups.any?

          settings << "- Actors: #{to_sentence(feature.actors_value.sort)}" if feature.actors_value.any?

          if feature.percentage_of_actors_value.positive?
            settings << "- #{feature.percentage_of_actors_value}% of actors"
          end

          settings << "- #{feature.percentage_of_time_value}% of the time" if feature.percentage_of_time_value.positive?
        end.join("\n")
      end

      def noteworthy?
        NOTEWORTHY_OPERATIONS.include?(operation)
      end

      def ==(other)
        other.is_a?(self.class) && feature == other.feature && operation == other.operation
      end

      private

      def action_taken
        case operation
        when "add"
          "added"
        when "clear"
          "cleared"
        when "remove"
          "removed"
        when "enable", "disable"
          "updated"
        else
          "" # noop
        end
      end

      def include_state?
        %w[enable disable].include?(operation)
      end

      def to_sentence(words)
        case words.length
        when 0
          ""
        when 1
          words.first.to_s
        when 2
          "#{words.first} and #{words.last}"
        else
          "#{words[0...-1].join(', ')} and #{words.last}"
        end
      end

    end
  end
end
