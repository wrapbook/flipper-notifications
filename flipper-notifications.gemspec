# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flipper/notifications/version"

Gem::Specification.new do |spec|
  spec.name          = "flipper-notifications"
  spec.version       = Flipper::Notifications::VERSION
  spec.authors       = ["Joel Lubrano"]
  spec.email         = ["jlubrano@wrapbook.com"]

  spec.summary       = %q{Rails-compatible Slack notifications for Flipper feature flags}
  spec.homepage      = "https://github.com/wrapbook/flipper-notifications"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 7.0"
  spec.add_runtime_dependency "flipper", "~> 0.24"
  spec.add_runtime_dependency "httparty", "~> 0.17"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency 'bundler-gem_version_tasks'
  spec.add_development_dependency "debug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"

  spec.add_development_dependency "activejob", "~> 7.0"
end
