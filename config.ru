require File.expand_path('./config/environment', File.dirname(__FILE__))

require 'sass/plugin/rack'
use Sass::Plugin::Rack

require 'acro_app'

map '/' do
  run AcroApp
end

require 'acro_api'

map '/acro/api' do
  run AcroApi
end

require 'rufus-scheduler'
require 'game'

Rufus::Scheduler.new.every "#{Game::TIME_PER_PHASE}s" do
  Game.tick!
end
