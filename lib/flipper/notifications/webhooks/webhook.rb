# frozen_string_literal: true

require "httparty"
require_relative "errors"

module Flipper
  module Notifications
    module Webhooks
      class Webhook

        include HTTParty

        default_timeout 5 # seconds
        raise_on 400..599

        def initialize(url:)
          @url = url
        end

        attr_reader :url

        def notify(**_kwargs)
          raise "Implement #notify in your subclass"
        end

        def serialized_attributes
          { url: url }
        end

        def ==(other)
          other.is_a?(self.class) && url == other.url
        end

        private

        def webhook_api_errors(&block)
          block.call
        rescue HTTParty::ResponseError => e
          error = e.response.code.to_i < 500 ? ClientError : ServerError
          raise error, e.response
        rescue Errno::ECONNRESET, Timeout::Error => e
          raise NetworkError, e
        end

      end
    end
  end
end
