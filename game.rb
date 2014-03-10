
class Game
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
end
