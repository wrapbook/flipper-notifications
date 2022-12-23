# frozen_string_literal: true

require "webmock/rspec/matchers"
require "support/shared_examples/webhook"

RSpec.describe Flipper::Notifications::Webhooks::Slack do
  include WebMock::Matchers

  describe "#notify", :webmock do
    subject(:notify_webhook) { webhook.notify(event: event, context_markdown: context_markdown) }

    let(:url) { "https://api.slack.test" }
    let(:user) { nil }
    let(:webhook) { described_class.new(url: url) }
    let(:stub_request) { WebMock.stub_request(:post, url) }
    let(:context_markdown) { "Test (changed by: Unknown)" }

    let(:event) do
      instance_double(
        Flipper::Notifications::FeatureEvent,
        summary_markdown:                  "test summary markdown",
        feature_enabled_settings_markdown: "test feature markdown"
      )
    end

    it_behaves_like "a webhook"

    it "sends a request to a Slack webhook" do
      expected_body = {
        blocks: [
          {
            type: "section",
            text: {
              type: described_class::MARKDOWN,
              text: "test summary markdown\ntest feature markdown"
            }
          },
          {
            type:     "context",
            elements: [
              {
                type: described_class::MARKDOWN,
                text: "Test (changed by: Unknown)"
              }
            ]
          }
        ]
      }

      request = stub_request.with(body: expected_body).to_return(body: "ok", status: 200)

      notify_webhook

      expect(request).to have_been_requested
    end

    context "when no context_markdown is provided" do
      it "omits context block from the request" do
        expected_body = {
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "test summary markdown\ntest feature markdown"
              }
            }
          ]
        }

        request = stub_request.with(body: expected_body).to_return(body: "ok", status: 200)

        webhook.notify(event: event)

        expect(request).to have_been_requested
      end
    end
  end
end
