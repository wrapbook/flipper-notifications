# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"

class TestFlipperNotifications < Minitest::Test
  include ActiveJob::TestHelper

  def setup
    @feature_name = :test_feature
  end

  def test_sanity
    assert_equal(true, true)
  end

  # See configuration of Flipper::Notifications in config/initializers/flipper.rb
  def test_flipper_notifications_railtie
    expected_args = ->(job_args) do
      job_args.first => {webhook:, event:}

      assert webhook.is_a?(Flipper::Notifications::Webhooks::Slack)

      assert_equal(event.feature, Flipper.feature(@feature_name))
      assert_equal(event.operation, "enable")
    end

    assert_enqueued_with(job: Flipper::Notifications::WebhookNotificationJob, args: expected_args) do
      Flipper.enable(@feature_name)
    end
  end
end
