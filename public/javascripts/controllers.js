angular.module('acroApp.controllers', ['ngCookies'])
  .controller('GameController', ['$scope', 'Player', '$location', 'Game', function($scope, Player, $location, Game) {
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
      $scope.player.setVoted();
      Player.submitVote({player_id: $scope.player.uuid, entry: $scope.player.chosenEntry});
    };
    $scope.submitEntry = function(){
      Player.submitEntry({player_id: $scope.player.uuid, acro: $scope.game.acro, expansion: $scope.player.suggestedExpansion}).$then(function(entry){
        $scope.player.setCurrentEntry(entry);
      });
    };
    $scope.joinGame = function(){
      Player.joinGame($scope.player).$then(function(response){
        $scope.player.updateInfo(response.data); // update the player object
        $scope.game.addPlayer(response.data); // update the game object
        $location.path('/main');
      });
    };
    $scope.roundNumber = function(){
      return $scope.game.round_number;
    };
  }]);