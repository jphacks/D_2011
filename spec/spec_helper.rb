# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default, :development, :test
Dotenv.load

SimpleCov.start
# SimpleCov.formatter = SimpleCov::Formatter::Codecov

require './src/aika'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  def app
    Aika
  end
end
