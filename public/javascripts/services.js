angular.module('acroApp.services', ['ngResource'])
  .factory('Player', ['$resource', '$cookies', function($resource, $cookies){
    var player = $resource('/acro/api/v1/player', null, {
      joinGame: {method: 'POST'},
      submitEntry: {method: 'POST', url: '/acro/api/v1/player/:player_id/entry', params: {player_id: '@player_id'}},
      submitVote: {method: 'POST', url: '/acro/api/v1/player/:player_id/vote', params: {player_id: '@player_id'}}
    });
    player.prototype.fromStore = function(){
      if(angular.isDefined($cookies.player)){
        return angular.fromJson($cookies.player);
      }else{
        return undefined;
      }
    }
    player.prototype.updateInfo = function(data){
      this.uuid           = data.uuid;
      this.name           = data.name;
      this.requestedName  = data.requestedName;
      $cookies.player     = this.serialize(); //store the player in a cookie to read it if the user refresh
    };
    player.prototype.serialize = function(){
      return angular.toJson(this);
    };
    player.prototype.setCurrentEntry = function(entry){
      this.entry = entry;
    }
    return player;
  }])
  .factory('Game', ['$resource', function($resource){
    var game = $resource('/acro/api/v1/game',
      {
        name: '@name'
      }, {});
    game.prototype.hasPlayer = function(uuid){
      var exists = false;
      angular.forEach(this.players, function(player){
        if(player.uuid == uuid)
          exists = true;
      });
      return exists;
    }
    game.prototype.phaseSecLeft = function(){
      var ends_at = new Date(this.phase_ends_at).getUTCSeconds();
      var now     = new Date().getUTCSeconds();
      if (ends_at - now){
        return (ends_at - now);
      }else{
        return -1;
      }
    }
    game.prototype.updateInfo = function(data){
      this.phase_ends_at  = data.phase_ends_at;
      this.phase          = data.phase;
      this.round_number   = data.round_number;
      this.players        = data.players;
      this.entries        = data.entries;
      this.winner         = data.winner;
      this.results        = data.results;
      this.acro           = data.acro;
    }
    game.prototype.addPlayer = function(player){
      this.players.push(player);
    }
    return game;
  }])
  .value('version', '0.1');