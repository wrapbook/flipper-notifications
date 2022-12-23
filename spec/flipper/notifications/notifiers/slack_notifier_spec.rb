# frozen_string_literal: true

require "support/shared_examples/active_job_serializable"
require "flipper/notifications/notifiers/webhook_notifier"
require "flipper/notifications/webhooks/webhook"

RSpec.describe Flipper::Notifications::Notifiers::WebhookNotifier do
  include_context "ActiveJob testing"

  let(:webhook) { "test webhook" }
  let(:notifier) { described_class.new(webhook: webhook) }

  describe "#call" do
    it "enqueues a WebhookNotificationJob" do
      expect do
        notifier.call(event: "event")
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end
  end
end
