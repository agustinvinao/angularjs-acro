require 'securerandom'
class Game < Hash

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

  attr_accessor :uuid, :round_number, :phase, :phase_ends_at, :acro, :players, :winner, :results

  def initialize
    @uuid           = SecureRandom.uuid # Game UUID
    @round_number   = 1                 # Starts with 1
    @phase          = PHASE_PLAY        # One of: play, vote, results
    @acro           = generateRandomAcrom
    @players        = []
    @winner         = nil
    @results        = nil
    @phase_ends_at  = nil # we set the this when we have the first player,
                          # meanwhile we are waiting for players
  end

  class << self
    def instance
      @@game ||= Game.new
    end
    def tick!
      puts "Game phase ticker"
      # TODO: Do something to foward the game
    end
  end

  # TODO: Implement the game class here

  private

  def reset_timer
    @phase_ends_at = Time.at(Time.now.tv_sec + TIME_PER_PHASE)
  end

  def generateRandomAcrom
    alphabet = ('A'..'Z').to_a
    (2.upto(MAX_ACROM_SIZE)).to_a.sample.times.map{|item| alphabet.sample }.join('')
  end
end