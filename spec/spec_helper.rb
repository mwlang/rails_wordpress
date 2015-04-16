ENV['RAILS_ENV'] ||= 'test'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'factory_girl'

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }

