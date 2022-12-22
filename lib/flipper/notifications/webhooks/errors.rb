# frozen_string_literal: true

module Flipper
  module Notifications
    module Webhooks
      class ApiError < StandardError
        def initialize(response)
          @response = response
        end

        def message
          "Webhook API call resulted in #{@response.code} response: #{@response.body}"
        end
      end

      class ClientError < ApiError; end

      class ServerError < ApiError; end

      class NetworkError < ApiError
        def initialize(cause)
          @cause = cause
        end

        def message
          "Webhook API call network error: #{cause.class.name} - #{cause.message}"
        end
      end
    end
  end
end
