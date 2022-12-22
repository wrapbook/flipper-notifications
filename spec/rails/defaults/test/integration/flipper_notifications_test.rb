# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"

class TestFlipperNotifications < Minitest::Test
  def setup
    @feature_name = :test_feature
  end

  def test_sanity
    assert_equal(true, true)
  end

  def test_flipper_notifications_railtie
    Flipper.enable(@feature_name)
    assert_enqueued_with(job: Flipper::Notifications::WebhookNotificationJob)
  end
end
