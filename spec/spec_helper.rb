# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default, :development, :test
Dotenv.load
SimpleCov.start

require './src/aika'

# SimpleCov.formatter = SimpleCov::Formatter::Codecov

RSpec.configure do |config|
  ENV['ENV'] = 'test'

  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  ActiveRecord::MigrationContext.new('db/migrate').migrate

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    FactoryBot.find_definitions
    DatabaseCleaner.start
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

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
