# frozen_string_literal: true

require_relative "webhook"

module Flipper
  module Notifications
    module Webhooks
      class Slack < Webhook
        MARKDOWN = "mrkdwn"

        headers "Content-type" => "application/json"

        def notify(event:, context_markdown: nil)
          webhook_api_errors do
            self.class.post(url, body: request_body(event: event, context_markdown: context_markdown))
          end
        end

        private

        def request_body(event:, context_markdown:)
          { blocks: blocks(event: event, context_markdown: context_markdown) }.to_json
        end

        def blocks(event:, context_markdown:)
          [
            feature_section(event: event),
            context_block(context_markdown: context_markdown)
          ].compact
        end

        def feature_section(event:)
          {
            type: "section",
            text: {
              type: MARKDOWN,
              text: "#{event.summary_markdown}\n#{event.feature_enabled_settings_markdown}".strip
            }
          }
        end

        def context_block(context_markdown:)
          return if context_markdown.nil?

          {
            type:     "context",
            elements: [
              {
                type: MARKDOWN,
                text: context_markdown
              }
            ]
          }
        end
      end
    end
  end
end
