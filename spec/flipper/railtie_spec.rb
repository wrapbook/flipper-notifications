# frozen_string_literal: true

require "active_job"

RSpec.describe Flipper::Notifications, skip: true do
  let(:admin) { users(:admin) }
  let(:webhook) { described_class::Webhooks::Slack.new(url: "test url") }

  let(:job) do
    Class.new(ActiveJob::Base) do
      def perform(webhook:, event:, context_markdown: nil)
      end
    end
  end

  before do
    stub_const("WebhookNotificationJob", job)

    # Maybe there's an initialize_defaults! or something that configures all of
    # this.  Or maybe there's a railtie tested separately...
    described_class.configure do |config|
      config.enabled   = true
      config.scheduler =
      config.webhooks  = [webhook]
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

