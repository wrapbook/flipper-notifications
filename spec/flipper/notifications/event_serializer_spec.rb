# frozen_string_literal: true

require "flipper/notifications/event_serializer"
require "support/shared_examples/active_job_serializable"

RSpec.describe Flipper::Notifications::EventSerializer do
  let(:event) { Flipper::Notifications::FeatureEvent.new(feature_name: "test", operation: "add") }

  it_behaves_like "an ActiveJob serializer" do
    let(:serializer) { described_class }
    let(:serializable) { event }
  end
end
