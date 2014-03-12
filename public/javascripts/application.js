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
      // TODO: Needs to move this verification to a service or factory
      var player = $rootScope.player.fromStore();
      // if the cookies has player data we need to verify if the user exists in game
      if (player){
        if ($rootScope.game.hasPlayer(player.uuid) == true){
          // we check if the player stored in cookies belongs to the current game
          // if the user belongs to the current game redirects to play it
          $rootScope.player.updateInfo(player);
          $location.path('/main');
        }else{
          // if the player not belongs to the current game we need to remove it from cookies and redirects the player
          // to set a new handler
          delete $cookies.player;
          $location.path('/');
        }
      }else{
        $cookies.player = $rootScope.player.serialize();
      }
    });
  }]);


