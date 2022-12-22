# frozen_string_literal: true

RSpec.shared_examples "an ActiveJob serializer" do
  # required_let_definitions :serializable, :serializer

  include ActiveJob::TestHelper

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

  around do |ex|
    queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    ex.run
  ensure
    clear_enqueued_jobs
    ActiveJob::Base.queue_adapter = queue_adapter
  end

  before do
    ActiveJob::Base.logger.level = Logger::WARN
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

