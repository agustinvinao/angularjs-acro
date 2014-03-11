require 'securerandom'
require_relative 'player.rb'
require_relative 'entry.rb'
require_relative 'vote.rb'
module Entities
  class Entry < Grape::Entity
    expose :uuid, :expansion
  end
end
class Game < Hash
  include Hashie::Extensions::MethodAccess
  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :round_number, :phase, :phase_ends_at, :acro
    expose :players, using: Player::Entity
    expose :entries, using: Entities::Entry do |entries, options|
      entries._entries # entries it should be an Array but for some reason is the Game instance.
    end
    expose :results, :winner, if: lambda { |instance, options| instance.phase == PHASE_RESULTS }
  end

  TIME_PER_PHASE  = 5 # value in seconds
  TOTAL_ROUNDS    = 10
  PHASE_PLAY      = 'play'
  PHASE_VOTE      = 'vote'
  PHASE_RESULTS   = 'results'
  PHASES          = [PHASE_PLAY, PHASE_VOTE, PHASE_RESULTS]
  MAX_ACROM_SIZE  = 5

  def initialize(hash = {})
    super
    self['uuid']           = SecureRandom.uuid # Game UUID
    self['round_number']   = 1                 # Starts with 1
    self['phase']          = PHASE_PLAY        # One of: play, vote, results
    self['acro']           = generateRandomAcrom
    self['players']        = []
    self['winner']         = nil
    self['entries']        = []
    self['results']        = nil
    self['phase_ends_at']  = nil # we set the this when we have the first player,
                                 # meanwhile we are waiting for players
    self['votes']          = []
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
    if self['players'].size > 0
      current_phase_index = PHASES.index(self['phase'])
      if current_phase_index + 1 == PHASES.size
        self['phase'] = PHASE_PLAY
      else
        self['phase'] = PHASES[current_phase_index + 1]
      end
      self['phase_ends_at'] = new_time
      puts "Phase: #{self['phase']} ends at: #{self['phase_ends_at']}"
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
    entry     = Entry.new({acro: acro, expansion: expansion, accepted: is_valid})
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


  def new_time
    #puts "timer resetted"
    Time.at(Time.now.tv_sec + TIME_PER_PHASE)
  end

  def generateRandomAcrom
    alphabet = ('A'..'Z').to_a
    (2.upto(MAX_ACROM_SIZE)).to_a.sample.times.map{|item| alphabet.sample }.join('')
  end
end