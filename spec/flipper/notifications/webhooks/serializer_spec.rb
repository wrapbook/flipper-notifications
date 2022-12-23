# frozen_string_literal: true

require "flipper/notifications/webhooks/serializer"
require "support/shared_examples/active_job_serializable"

RSpec.describe Flipper::Notifications::Webhooks::Serializer do
  let(:webhook) { Flipper::Notifications::Webhooks::Webhook.new(url: "test url") }

  it_behaves_like "an ActiveJob serializer" do
    let(:serializer) { described_class }
    let(:serializable) { webhook }
  end
end
