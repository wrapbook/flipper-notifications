# frozen_string_literal: true

RSpec.describe Flipper::Notifications::Configuration do
  let(:config) { described_class.new }

  it { expect(config).to respond_to(:enabled) }
  it { expect(config).to respond_to(:notifiers) }
  it { expect(config).to respond_to(:enabled?) }
end
