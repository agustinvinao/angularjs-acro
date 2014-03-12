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
    desc 'Add a player'
    params do
      requires :name, type: String
    end
    get do
      present game, with: Game::Entity
    end
  end

  namespace :player do
    desc 'Join the game'
    params do
      requires :requestedName, type: String
    end
    post do
      player = game.newPlayer(params[:requestedName])
      player2 = player.clone
      player2['score'] = nil
      present player2, with: Player::Entity
    end

    desc 'Get player info'
    params do
      requires :player_id, type: String
    end
    get '/:player_id' do
      present game.getPlayer(params[:player_id]), with: Player::Entity
    end

    desc 'Submit an entry'
    params do
      requires :acro, type: String
      requires :expansion, type: String
    end
    post '/:player_id/entry' do
      # TODO: when the user updates the entry
      entry = game.newPlayerEntry(params[:player_id], params[:acro], params[:expansion])
      #if entry.accepted
      #  present entry, with: Entry::Entity
      #else
      #  # redirect '/:player_id/entry', {status: 200}
      #  present entry, with: Entry::Entity
      #end
      entry.accepted ? present(entry, with: Entry::Entity) : present(entry, with: Entry::Entity)
    end


    desc 'Submit a vote'
    params do
      requires :entry, type: String
    end
    post '/:player_id/vote' do
      # TODO: Implement accepting a vote
      vote = game.registerPlayerVote(params[:player_id], params[:entry])
      vote.accepted ? present(vote, vith: Vote::Entity) : present(vote, vith: Vote::Entity)
    end
  end
end
