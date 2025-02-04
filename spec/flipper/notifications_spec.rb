# frozen_string_literal: true

require "active_support/isolated_execution_state"

RSpec.describe Flipper::Notifications do
  it "has a version number" do
    expect(Flipper::Notifications::VERSION).not_to be nil
  end

  describe "configure" do
    it "yields the configuration to a block" do
      described_class.configure do |config|
        expect(config).to be_a(Flipper::Notifications::Configuration)
        expect(config).to be(Flipper::Notifications.configuration)
      end
    end
  end

  describe "notifications" do
    let(:webhook) { described_class::Webhooks::Slack.new(url: "test url") }
    let(:notifier) { double("notifier", call: nil) }

    before do
      Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new, instrumenter: ActiveSupport::Notifications)

      described_class.configure do |config|
        config.enabled   = true
        config.notifiers = [notifier]
      end

      described_class.subscribe!
    end

    after do
      described_class.configure { |config| config.enabled = false }
      described_class.unsubscribe!
    end

    it "notifies when a feature is added" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "add"
      )

      Flipper.add(:test)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is enabled" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "enable"
      )

      Flipper.enable(:test)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is enabled for a group" do
      event = described_class::FeatureEvent.new(
        feature_name: "group_test",
        operation:    "enable"
      )

      Flipper.enable_group(:group_test, :test_group)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is enabled for a percentage of actors" do
      event = described_class::FeatureEvent.new(
        feature_name: "actors_percentage_test",
        operation:    "enable"
      )

      Flipper.enable_percentage_of_actors(:actors_percentage_test, 50)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is enabled for a percentage of time" do
      event = described_class::FeatureEvent.new(
        feature_name: "time_percentage_test",
        operation:    "enable"
      )

      Flipper.enable_percentage_of_time(:time_percentage_test, 25)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is disabled" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "disable"
      )

      Flipper.disable(:test)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is disable for a group" do
      event = described_class::FeatureEvent.new(
        feature_name: "group_test",
        operation:    "disable"
      )

      Flipper.disable_group(:group_test, :test_group)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is removed" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "remove"
      )

      Flipper.remove(:test)
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "notifies when a feature is cleared" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "clear"
      )

      Flipper[:test].clear
      expect(notifier).to have_received(:call).with(event: event)
    end

    it "only notifies for noteworthy events" do
      Flipper.exist?(:test)
      expect(notifier).not_to have_received(:call)
    end

    context "when FlipperNotifications is disabled" do
      it "does not notify" do
        described_class.configure { |config| config.enabled = false }

        Flipper.add(:test)
        expect(notifier).not_to have_received(:call)
      end
    end

    describe "temporarily disabling notifications" do
      it "does not notify on events within the block passed to #disabled" do
        Flipper::Notifications.disabled do
          Flipper.add(:test)
        end

        expect(notifier).not_to have_received(:call)
      end

      it "restores the previously configured value after the block is run" do
        described_class.configuration.enabled = true
        described_class.disabled { Flipper.add(:test) }
        expect(described_class.configuration.enabled).to be true

        described_class.configuration.enabled = false
        described_class.disabled { Flipper.add(:test) }
        expect(described_class.configuration.enabled).to be false
      end
    end
  end
end
