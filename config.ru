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

# check how to resolve when is going to start a game and synchronize with this.
# we can put a button to set ready to all players and when all are ready create the new game.
Rufus::Scheduler.new.every '30s' do
  Game.tick!
end
