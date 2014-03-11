require 'rubygems'

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'

require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end

require_relative '../acro_api.rb'
require_relative 'support/json_helpers.rb'
require_relative '../game.rb'