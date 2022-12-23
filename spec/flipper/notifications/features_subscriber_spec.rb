# frozen_string_literal: true

require "time"
require "flipper/notifications/features_subscriber"

RSpec.describe Flipper::Notifications::FeaturesSubscriber do
  describe "#call" do
    subject(:call_subscriber) do
      described_class.new.call(name, start, finish, id, payload)
    end

    let(:name)   { Flipper::Feature::InstrumentationName }
    let(:start)  { Time.new(2022, 12, 21, 12) }
    let(:finish) { Time.new(2022, 12, 21, 13) }
    let(:id)     { "test_id" }

    let(:payload) do
      {
        feature_name: "test",
        operation:    "add"
      }
    end

    context "when FlipperNotifications are enabled" do
      let(:event) { Flipper::Notifications::FeatureEvent.new(**payload) }

      around do |example|
        Flipper::Notifications.configure { |config| config.enabled = true }
        example.run
      ensure
        Flipper::Notifications.configure { |config| config.enabled = false }
      end

      it "notifies for the event" do
        expect(Flipper::Notifications).to receive(:notify).with(event: event)
        call_subscriber
      end

      it "only notifies for noteworthy events" do
        allow_any_instance_of(event.class).to receive(:noteworthy?).and_return(false)
        expect(Flipper::Notifications).not_to receive(:notify)
        call_subscriber
      end
    end

    context "when FlipperNotifications are disabled" do
      it "does nothing" do
        expect(Flipper::Notifications::FeatureEvent).not_to receive(:from_active_support)
        expect(Flipper::Notifications).not_to receive(:notify)
        call_subscriber
      end
    end
  end
end
