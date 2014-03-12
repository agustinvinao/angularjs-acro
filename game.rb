require 'securerandom'
require_relative 'player.rb'
require_relative 'entry.rb'
require_relative 'vote.rb'
module Entities
  class Entry < Grape::Entity
    expose :uuid, :expansion, :player_id
  end
end
class Game < Hash
  include Hashie::Extensions::MethodAccess
  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    format_with(:iso_timestamp) { |dt| dt.iso8601 unless dt.nil? }

    expose :uuid, :round_number, :phase, :acro
    with_options(format_with: :iso_timestamp) do
      expose :phase_ends_at
    end
    expose :players, using: Player::Entity
    expose :entries, using: Entities::Entry do |entries, options|
      entries._entries # entries it should be an Array but for some reason is the Game instance.
    end
    expose :results, :winner, if: lambda { |instance, options| instance.phase == PHASE_RESULTS }
  end

  TIME_PER_PHASE  = 20 # value in seconds
  TOTAL_ROUNDS    = 10
  MAX_POINTS      = 10
  PHASE_PLAY      = 'play'
  PHASE_VOTE      = 'vote'
  PHASE_RESULTS   = 'result'
  PHASES          = [PHASE_PLAY, PHASE_VOTE, PHASE_RESULTS]
  MAX_ACROM_SIZE  = 5

  def initialize(hash = {})
    super
    self['uuid'] = SecureRandom.uuid # Game UUID
    new_time!
    reset!
  end

  def _entries
    self['entries']
  end

  class << self
    def instance
      @@game ||= Game.new
    end
    def tick!
      #puts "Game phase ticker"
      Game.instance.resetPhase!
    end
  end

  def resetPhase!
    new_time!
    current_phase_index = PHASES.index(self['phase'])
    if self['players'].size > 0
      if current_phase_index + 1 == PHASES.size
        self['round_number'] += 1
        self['phase'] = PHASE_PLAY
      else
        self['phase'] = PHASES[current_phase_index + 1]
      end
      if self['phase'] == PHASE_RESULTS
        ## resutls
        self['results']     = []
        votes               = self['votes'].keep_if{|vote| !(vote.entry =~ /none/) }
        votes_players_uuids = self['votes'].map(&:player_id)
        votes_by_player     = votes.group_by{|h| h['player_id'] }
        votes_by_player.keys.each do |player_uuid|
          if votes_players_uuids.include?(player_uuid)
            self['results'] << {player: player_uuid, votes: votes_by_player[player_uuid].size, expansion: ''}
            player = selectPlayer(player_uuid)
            player.score = player.score.to_i + votes_by_player[player_uuid].size
          end
        end
        ## winner
        self['winner'] = self['results'].max_by{|r| r['votes']} if self['results'].size > 0
      end

      reset! if self['round_number'] > TOTAL_ROUNDS || self.players.map(&:score).max >= MAX_POINTS
    end
  end

  def newPlayer(name)
    player = Player.new(hasName?(name) ? {name: fixUserNames(name), requested_name: name} : {name: name})
    self['players'] << player
    player
  end

  def getPlayer(player_id)
    self['players'].detect{|player| player.uuid == player_id}
  end

  def newPlayerEntry(player_id, acro, expansion)
    is_valid  = isValidExpansion?(acro, expansion)
    entry     = Entry.new({acro: acro, expansion: expansion, accepted: is_valid, player_id: player_id})
    self['entries'].delete_if{|e| e.player_id == player_id}
    self['entries'] << entry if is_valid
    entry
  end

  def registerPlayerVote(player_id, entry)
    is_valid  = isValidVote?
    vote      = Vote.new({entry: entry, accepted: is_valid, player_id: player_id})
    self['votes'] << vote if is_valid
    vote
  end

  private
  def reset!
    self['round_number']  = 1
    self['players']       = []
    self['entries']       = []
    self['winner']        = nil
    self['results']       = []
    self['phase']         = PHASE_PLAY
    self['acro']          = generateRandomAcrom
    self['votes']         = []
    self['entries']        = []

  end

  def isValidVote?
    #puts "current phase: #{self['phase']}"
    self['phase'] == PHASE_VOTE && self['phase_ends_at'] >= Time.now
  end

  def isValidExpansion?(acro, expansion)
    expansion.scan(/\b\w/).join.upcase == acro
  end

  def hasName?(name)
    duplicatedNames(name).size > 0
  end

  def fixUserNames(name)
    max = duplicatedNames(name).map{|item| item.gsub(/#{name}/, '')}.keep_if{|item| !item.empty?}.max
    "#{name}#{max.to_i+1}"
  end

  def duplicatedNames(name)
    self['players'].map(&:name).select{|n| n.start_with?(name)}
  end


  def new_time!
    time = Time.at(Time.now.tv_sec + TIME_PER_PHASE)
    self['phase_ends_at'] = time
    time
  end

  def generateRandomAcrom
    alphabet = ('A'..'Z').to_a
    (2.upto(MAX_ACROM_SIZE)).to_a.sample.times.map{|item| alphabet.sample }.join('')
  end

  def selectEntry(uuid)
    self['entries'].detect{|e| e.uuid =~ /#{uuid}/}
  end

  def playerHasVoted(uuid)
    self['votes'].detect{|v| v.uuid =~ /#{uuid}/}
  end
  def selectPlayer(uuid)
    self['players'].detect{|p| p.uuid =~ /#{uuid}/}
  end

end