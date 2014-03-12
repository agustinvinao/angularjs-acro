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


### Player name required:

In the original api code this parameter is not required, but from the requirements 'users go to a website and sign in
using a handle.' I assume we need to defined as required


In Game object the method hasPlayer use a forEach call to detect if a player exists in this game, the library underscorejs
provides a better way to do it.


### setInteval

In GameController I'm using setInterval to handle the timer in the main view. $interval it was added in AngularJS 1.2.rc3
$timeout don't provide the same functionality.
It should be better to move this code to a directive, but the main view has a function that needs to be in the controller.


### Game entries

A player can improve their entry, because of this we should store the player_id (uuid) in game entries to update the
correspondent entry if a player updates it.