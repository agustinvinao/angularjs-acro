require 'rubygems'

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'

require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end

require_relative '../acro_api.rb'


#ENV['RACK_ENV'] = 'test'
#require 'minitest/autorun'
#require 'rack/test'
#require 'json'
#require 'grape'
#require 'logger'
#Grape::API.logger = Logger.new('/dev/null')
#
#require_relative '../acro_app.rb'
#require_relative '../acro_api.rb'
#
#
##class TestClient
##  include MiniTest::Assertions
##
##  attr_accessor :rack_test, :default_headers
##
##  def initialize(headers = {})
##    self.rack_test       = ::TestClient::RackTest.new
##    self.default_headers = headers
##  end
##
##  %w(get post put delete).each do |method|
##    define_method(method) do |path, params={}, headers={}|
##      JsonResponse.new(rack_test.send(method, path, params, default_headers.merge(headers)))
##    end
##  end
##
##  class RackTest
##    include Rack::Test::Methods
##
##    def app
##      Muon::API::Application
##    end
##  end
##
##  class JsonResponse
##    attr_reader :response
##    delegate :status, :headers, to: :response
##
##    def initialize(response)
##      @response = response
##    end
##
##    def body
##      @body ||= begin
##        @response.body.empty?? @response.body : JSON.parse(@response.body)
##      end
##    end
##  end
##end
#
##class Muon::API::TestCase < MiniTest::Unit::TestCase
##  def setup
##    headers = {'HTTP_ACCEPT' => 'application/vnd.muon-v1+json'}
##    @client = TestClient.new(headers)
##  end
##
##  def teardown
##    DatabaseCleaner.clean
##  end
##end