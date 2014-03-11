require 'securerandom'
require_relative 'player.rb'
class Game < Hash
  include Hashie::Extensions::MethodAccess
  def entity
    Entity.new(self)
  end

  class Entity < Grape::Entity
    expose :uuid, :round_number, :phase, :phase_ends_at, :acro, :players, :winner
    expose :results, if: lambda { |instance, options| instance.phase == PHASE_RESULTS }
  end

  TIME_PER_PHASE  = 30 # value in seconds
  TOTAL_ROUNDS    = 10
  PHASE_PLAY      = 'play'
  PHASE_VOTE      = 'vote'
  PHASE_RESULTS   = 'results'
  MAX_ACROM_SIZE  = 5

  def initialize(hash = {})
    super
    self['uuid']           = SecureRandom.uuid # Game UUID
    self['round_number']   = 1                 # Starts with 1
    self['phase']          = PHASE_PLAY        # One of: play, vote, results
    self['acro']           = generateRandomAcrom
    self['players']        = []
    self['winner']         = nil
    self['results']        = nil
    self['phase_ends_at']  = nil # we set the this when we have the first player,
                          # meanwhile we are waiting for players
  end

  class << self
    def instance
      @@game ||= Game.new
    end
    def tick!
      puts "Game phase ticker"
      Game.instance.resetPhase!
    end
  end

  def resetPhase!
    self['phase_ends_at'] = new_time if self['players'].size > 0
  end

  def newPlayer(name)
    player = Player.new(hasName?(name) ? {name: fixUserNames(name), requested_name: name} : {name: name})
    self['players'] << player
    player
  end

  def getPlayer(player_id)
    self['players'].detect{|player| player.uuid == player_id}
  end

  private

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
    puts "timer resetted"
    Time.at(Time.now.tv_sec + TIME_PER_PHASE)
  end

  def generateRandomAcrom
    alphabet = ('A'..'Z').to_a
    (2.upto(MAX_ACROM_SIZE)).to_a.sample.times.map{|item| alphabet.sample }.join('')
  end
end