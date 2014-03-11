Notes during development:

### Class Gamer, initialize phase_ends_at as nil:

The reason behind this is than the games needs a uniq point where it fires the phase counter.

Inside config.ru we have to handle this

```ruby
Rufus::Scheduler.new.every '30s' do
  Game.tick!
end
```

only when the game has players it's going to have phase_ends_at with value.

### Game behavior:

When a player register to play the game, next call to Game.tick! if going to start the first phase of the first round in
the game. This behavior runs the game with at least one player.

### Alternative approach:

As an alternative approach we can define that all players in a game need to change their status from waiting to ready as
a flag to starts the game. This approach runs the game with 1 or more player depending on player's state.