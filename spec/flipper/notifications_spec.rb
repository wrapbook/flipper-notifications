# frozen_string_literal: true

require "active_support/isolated_execution_state"

RSpec.describe Flipper::Notifications do
  it "has a version number" do
    expect(Flipper::Notifications::VERSION).not_to be nil
  end

  describe "notifications" do
    let(:admin) { users(:admin) }
    let(:webhook) { described_class::Webhooks::Slack.new(url: "test url") }
    let(:scheduler) { double("scheduler", call: nil) }

    before do
      Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new, instrumenter: ActiveSupport::Notifications)

      described_class.configure do |config|
        config.enabled   = true
        config.scheduler = scheduler
        config.webhooks  = [webhook]
      end

      described_class.subscribe!
    end

    after do
      described_class.configure { |config| config.enabled = false }
      described_class.unsubscribe!
    end

    it "calls the scheduler when a feature is added" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "add"
      )

      Flipper.add(:test)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is enabled" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "enable"
      )

      Flipper.enable(:test)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is enabled for a group" do
      event = described_class::FeatureEvent.new(
        feature_name: "group_test",
        operation:    "enable"
      )

      Flipper.enable_group(:group_test, :test_group)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is enabled for a percentage of actors" do
      event = described_class::FeatureEvent.new(
        feature_name: "actors_percentage_test",
        operation:    "enable"
      )

      Flipper.enable_percentage_of_actors(:actors_percentage_test, 50)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is enabled for a percentage of time" do
      event = described_class::FeatureEvent.new(
        feature_name: "time_percentage_test",
        operation:    "enable"
      )

      Flipper.enable_percentage_of_time(:time_percentage_test, 25)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is disabled" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "disable"
      )

      Flipper.disable(:test)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is disable for a group" do
      event = described_class::FeatureEvent.new(
        feature_name: "group_test",
        operation:    "disable"
      )

      Flipper.disable_group(:group_test, :test_group)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is removed" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "remove"
      )

      Flipper.remove(:test)
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "calls the scheduler when a feature is cleared" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "clear"
      )

      Flipper[:test].clear
      expect(scheduler).to have_received(:call).with(webhook: webhook, event: event)
    end

    it "only schedules for noteworthy events" do
      Flipper.exist?(:test)
      expect(scheduler).not_to have_received(:call)
    end

    context "when FlipperNotifications is disabled" do
      it "does not notify" do
        described_class.configure { |config| config.enabled = false }

        Flipper.add(:test)
        expect(scheduler).not_to have_received(:call)
      end
    end
  end
end
