angular.module('acroApp', ['acroApp.controllers', 'acroApp.services'])
  .config(['$routeProvider', function($routeProvider) {
    $routeProvider
      .when('/', {controller: 'GameController', templateUrl: '/templates/join.html'})
      .when('/main', {controller: 'GameController', templateUrl: '/templates/main.html'})
      .otherwise({redirectTo:'/'});
  }])
  .run(['$rootScope', 'Game', 'Player', '$cookies', '$location', function($rootScope, Game, Player, $cookies, $location){
    $rootScope.game = new Game;
    Game.get({name: 'test'}).$then(function(response){
      $rootScope.game.updateInfo(response.data);
      $rootScope.player = new Player;

      // TODO: Needs test for start status and cookie data read
      // if the cookies has player data we need to verify if the user exists in game
      if (angular.isDefined($cookies.player)){
        var player = angular.fromJson($cookies.player);
        if ($rootScope.game.hasPlayer(player.uuid) == true){
          $rootScope.player.updateInfo(player);
          $location.path('/main');
        }else{
          delete $cookies.player;
          $location.path('/');
        }
      }else{
        $cookies.player = $rootScope.player.serialize();
      }
    });

  }]);


angular.module('acroApp.services', ['ngResource'])
  .factory('Player', ['$resource', function($resource){
    var player = $resource('/acro/api/v1/player', null, {
        joinGame: {method: 'POST'},
        submitEntry: {method: 'POST', url: '/acro/api/v1/player/:player_id/entry', params: {player_id: '@player_id'}},
        submitVote: {method: 'POST', url: '/acro/api/v1/player/:player_id/vote', params: {player_id: '@player_id'}}
      });

    player.prototype.updateInfo = function(data){
      this.uuid = data.uuid;
      this.name = data.name;
      this.requestedName = data.requestedName;
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
    return game;
  }])
  .value('version', '0.1');

angular.module('acroApp.controllers', ['ngCookies'])
  .controller('GameController', ['$scope', 'Player', '$location', 'Game', '$cookies', function($scope, Player, $location, Game, $cookies) {
    $scope.secondsLeft = function(){
      return $scope.game.phaseSecLeft();
    }
    // we need to do different things by the path
    switch($location.path()){
      case '/main':
        // TODO: Need tests for setInterval function
        var waiting = false;
        setInterval(function(){
          if ($scope.game.phaseSecLeft() < 0 && !waiting){
            waiting = true;
            Game.get({name: 'test'}).$then(function(response){
              waiting = false;
              $scope.game.updateInfo(response.data);
            });
          }
          $scope.$apply();
        }, 1000);
        break;
    }
    $scope.playerHasVoted = function(){
      return angular.isDefined($scope.player.chosenEntry) && $scope.player.voted;
    }
    $scope.submitVote = function(){
      $scope.player.voted = true;
      Player.submitVote({player_id: $scope.player.uuid, entry: $scope.player.chosenEntry});
    };
    $scope.submitEntry = function(){
      Player.submitEntry({player_id: $scope.player.uuid, acro: $scope.game.acro, expansion: $scope.player.suggestedExpansion});
    };
    $scope.joinGame = function(){
      Player.joinGame($scope.player).$then(function(player){
        $scope.player.updateInfo(player.data); // update the player object
        // TODO: Move to Factory
        $scope.game.players.push(player.data); // update the game object
        // TODO: Move and test to Factory
        $cookies.player = $scope.player.serialize(); //store the player in a cookie to read it if the user refresh the screen
        $location.path('/main');
      });
    };
    $scope.roundNumber = function(){
      return $scope.game.round_number;
    };
  }]);
// TODO: check when the user set expasion and it has time, it shuold show to change it.