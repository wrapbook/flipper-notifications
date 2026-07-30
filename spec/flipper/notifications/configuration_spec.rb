# frozen_string_literal: true

RSpec.describe Flipper::Notifications::Configuration do
  let(:config) { described_class.new }

  it { expect(config).to respond_to(:enabled) }
  it { expect(config).to respond_to(:notifiers) }
  it { expect(config).to respond_to(:enabled?) }
  it { expect(config).to respond_to(:flipper) }
  it { expect(config).to respond_to(:flipper=) }

  describe "#flipper" do
    it "defaults to the global Flipper" do
      expect(config.flipper).to eq(Flipper)
    end

    it "returns the configured instance when set" do
      custom = Flipper.new(Flipper::Adapters::Memory.new)
      config.flipper = custom
      expect(config.flipper).to eq(custom)
    end

    it "falls back to the global Flipper when reset to nil" do
      config.flipper = Flipper.new(Flipper::Adapters::Memory.new)
      config.flipper = nil
      expect(config.flipper).to eq(Flipper)
    end
  end
end
