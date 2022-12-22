# frozen_string_literal: true

RSpec.describe Flipper::Notifications, skip: true do
  let(:admin) { users(:admin) }
  let(:webhook) { described_class::Webhooks::Slack.new(url: "test url") }

  around do |example|
    Current.user = admin

    RSpec::Mocks.with_temporary_scope { allow(webhook).to receive(:notify) }
    webhooks = described_class.configuration.webhooks

    described_class.configure do |config|
      config.enabled  = true
      config.webhooks = [webhook]
    end

    example.run
  ensure
    described_class.configure do |config|
      config.enabled  = false
      config.webhooks = webhooks
    end
  end

  it "notifies webhooks when a feature is added" do
    event = described_class::FeatureEvent.new(
      feature_name: "test",
      operation:    "add"
    )

    expect do
      Flipper.add(:test)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is enabled" do
    event = FlipperNotifications::FeatureEvent.new(
      feature_name: "test",
      operation:    "enable"
    )

    expect do
      Flipper.enable(:test)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is enabled for a group" do
    event = described_class::FeatureEvent.new(
      feature_name: "group_test",
      operation:    "enable"
    )

    expect do
      Flipper.enable_group(:group_test, :test_group)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is enabled for a percentage of actors" do
    event = described_class::FeatureEvent.new(
      feature_name: "actors_percentage_test",
      operation:    "enable"
    )

    expect do
      Flipper.enable_percentage_of_actors(:actors_percentage_test, 50)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is enabled for a percentage of time" do
    event = described_class::FeatureEvent.new(
      feature_name: "time_percentage_test",
      operation:    "enable"
    )

    expect do
      Flipper.enable_percentage_of_time(:time_percentage_test, 25)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is disabled" do
    event = described_class::FeatureEvent.new(
      feature_name: "test",
      operation:    "disable"
    )

    expect do
      Flipper.disable(:test)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is disable for a group" do
    event = described_class::FeatureEvent.new(
      feature_name: "group_test",
      operation:    "disable"
    )

    expect do
      Flipper.disable_group(:group_test, :test_group)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is removed" do
    event = described_class::FeatureEvent.new(
      feature_name: "test",
      operation:    "remove"
    )

    expect do
      Flipper.remove(:test)
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "notifies webhooks when a feature is cleared" do
    event = described_class::FeatureEvent.new(
      feature_name: "test",
      operation:    "clear"
    )

    expect do
      Flipper[:test].clear
    end.to have_enqueued_job(WebhookNotificationJob)
      .with(webhook: webhook, event: event, user: admin)
  end

  it "only notifies for noteworthy events" do
    expect do
      Flipper.exist?(:test)
    end.not_to have_enqueued_job(WebhookNotificationJob)
  end

  context "when the Current.user is not set" do
    let(:admin) { nil }

    it "includes the User for the webhook notification" do
      event = described_class::FeatureEvent.new(
        feature_name: "test",
        operation:    "add"
      )

      expect do
        Flipper.add(:test)
      end.to have_enqueued_job(WebhookNotificationJob)
        .with(webhook: webhook, event: event, user: nil)
    end
  end

  context "when FlipperNotifications is disabled" do
    it "does not notify" do
      described_class.configure { |config| config.enabled = false }

      expect do
        Flipper.add(:test)
      end.not_to have_enqueued_job(WebhookNotificationJob)
    end
  end
end

