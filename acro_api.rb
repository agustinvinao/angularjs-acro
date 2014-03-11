require 'grape'
require 'grape-entity'
require_relative 'game'
class AcroApi < Grape::API
  version 'v1', using: :path
  format :json

  helpers do
    def game
      Game.instance
    end
  end

  namespace :game do
    desc "Add a player"
    params do
      requires :name, type: String
    end
    get do
      present game, with: Game::Entity
    end
  end

  namespace :player do
    desc "Join the game"
    params do
      requires :name, type: String
    end
    post do
      present game.newPlayer(params[:name]), with: Player::Entity
    end

    desc "Get player info"
    params do
    end
    get '/:player_id' do
      # TODO: Implement returning player info
    end

    desc "Submit an entry"
    params do
      requires :acro, type: String
      requires :expansion, type: String
    end
    post '/:player_id/entry' do
      # TODO: Implement accepting an entry from a player
    end

    desc "Submit a vote"
    params do
      requires :entry, type: String
    end
    post '/:player_id/vote' do
      # TODO: Implement accepting a vote
    end
  end
end
