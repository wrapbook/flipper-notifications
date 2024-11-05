# frozen_string_literal: true

RSpec.describe Flipper::Notifications::FeatureEvent do
  let(:feature_name) { "TEST" }
  let(:feature)      { Flipper.feature(feature_name) }
  let(:operation)    { :enable }
  let(:event)        { described_class.new(feature_name: feature_name, operation: operation) }

  let(:user_class) do
    Class.new do
      def initialize(id:)
        @id = id
      end

      def flipper_id
        "User/#{@id}"
      end
    end
  end

  before do
    stub_const("User", user_class)
  end

  describe ".from_active_support" do
    let(:active_support_notification) do
      args = [
        "event_name",
        "start",
        "finish",
        "id",
        {
          feature_name: :test,
          operation:    :enable
        }
      ]

      ActiveSupport::Notifications::Event.new(*args)
    end

    it "returns a FeatureEvent" do
      event = described_class.from_active_support(event: active_support_notification)
      expect(event.feature).to eq(Flipper.feature(:test))
      expect(event.operation).to eq("enable")
    end
  end

  describe "#summary_markdown" do
    subject(:summary_markdown) { event.summary_markdown }

    {
      "add"    => "added",
      "clear"  => "cleared",
      "remove" => "removed"
    }.each do |operation, past_tense|
      context "when the feature was #{past_tense}" do
        let(:operation) { operation }

        it { is_expected.to eq("Feature *TEST* was #{past_tense}.") }
      end
    end

    context "when the feature is fully enabled" do
      let(:operation) { "enable" }

      before do
        feature.enable
      end

      it { is_expected.to eq("Feature *TEST* was updated. The feature is now *fully enabled.*") }
    end

    context "when the feature is fully disabled" do
      let(:operation) { "disable" }

      before do
        feature.disable
      end

      it { is_expected.to eq("Feature *TEST* was updated. The feature is now *fully disabled.*") }
    end

    context "when the feature is partially enabled" do
      let(:operation) { "enable" }

      before do
        feature.enable_percentage_of_actors(50)
      end

      it { is_expected.to eq("Feature *TEST* was updated.") }
    end
  end

  describe "#feature_enabled_settings_markdown" do
    subject(:markdown) { event.feature_enabled_settings_markdown }

    context "when the feature is fully enabled" do
      before do
        feature.enable
      end

      it { is_expected.to eq("") }
    end

    context "when the feature is fully disabled" do
      before do
        feature.disable
      end

      it { is_expected.to eq("") }
    end

    context "when the feature is partially enabled" do
      it "includes enabled groups" do
        feature.enable_group("test_group")
        expect(markdown).to match(/Groups: test_group/)
      end

      it "includes enabled actors" do
        user = User.new(id: 1)
        feature.enable_actor(user)
        expect(markdown).to match(/Actors: #{user.flipper_id}/)
      end

      it "includes two actors" do
        user = User.new(id: 1)
        user2 = User.new(id: 2)
        feature.enable_actor(user)
        feature.enable_actor(user2)

        expect(markdown).to match(/Actors: #{user.flipper_id} and #{user2.flipper_id}/)
      end

      it "includes several actors" do
        user = User.new(id: 1)
        user2 = User.new(id: 2)
        user3 = User.new(id: 3)
        feature.enable_actor(user)
        feature.enable_actor(user2)
        feature.enable_actor(user3)

        expect(markdown).to match(/Actors: #{user.flipper_id}, #{user2.flipper_id} and #{user3.flipper_id}/)
      end

      it "includes percentage of actors" do
        feature.enable_percentage_of_actors(50)
        expect(markdown).to match(/50% of actors/)
      end

      it "includes percentage of time" do
        feature.enable_percentage_of_time(25)
        expect(markdown).to match(/25% of the time/)
      end
    end
  end

  describe "#noteworthy?" do
    {
      "add"     => true,
      "enable"  => true,
      "disable" => true,
      "clear"   => true,
      "remove"  => true,
      "exist?"  => false
    }.each do |operation, noteworthiness|
      it "returns #{noteworthiness} for #{operation}" do
        event = described_class.new(feature_name: "test", operation: operation)
        expect(event.noteworthy?).to be(noteworthiness)
      end
    end
  end
end
