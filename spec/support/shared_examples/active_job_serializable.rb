# frozen_string_literal: true

RSpec.shared_context "ActiveJob testing" do
  include ActiveJob::TestHelper

  around do |ex|
    ActiveJob::Base.logger.level = Logger::WARN
    queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    ex.run
  ensure
    ActiveJob::Base.queue_adapter = queue_adapter
  end
end

RSpec.shared_examples "an ActiveJob serializer" do
  # required_let_definitions :serializable, :serializer

  include_context "ActiveJob testing"

  let(:job) do
    Class.new(ActiveJob::Base) do
      @last_thing = nil

      class << self

        attr_accessor :last_thing

      end

      def perform(thing)
        self.class.last_thing = thing
      end
    end
  end

  before do
    ActiveJob::Serializers.add_serializers(serializer)
    stub_const("TestEventSerializationJob", job)
  end

  it "can be serialized and deserialized by ActiveJob" do
    expect(job.last_thing).to be_nil

    perform_enqueued_jobs do
      job.perform_later(serializable)
    end

    expect(job.last_thing).to eq(serializable)
  end
end
