require "bundler/setup"
require "debug"
require "webmock/rspec"

require "flipper"
require "flipper/notifications"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Flipper.configure do |config|
      adapter = Flipper::Adapters::Memory.new
      instrumented = Flipper::Adapters::Instrumented.new(adapter, :instrumenter => ActiveSupport::Notifications)
    end
  end
end
