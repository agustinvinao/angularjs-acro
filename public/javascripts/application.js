angular.module('acroApp', ['acroApp.controllers', 'acroApp.services'])
  .config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    // TODO: module initialization. Set up routes.
    $routeProvider
      .when('/', {controller: 'GameController', templateUrl: '/templates/join.html'})
      .otherwise({redirectTo:'/'});
  }])
  .run(['$rootScope', 'Game', '$log', function($rootScope, Game, $log){
    Game.get({name: 'test'}, function(game) {
      $rootScope.game = new Game(game);
      $log.info('$scope.game: ', $scope.game)
    });
  }]);

angular.module('acroApp.services', ['ngResource'])
  .factory('Game', ['$resource', function($resource){
    function Game(data){
      this.uuid           = data.uuid;
      this.roundNumber    = data.round_number;
      this.phase          = data.phase;
      this.phase_ends_at  = data.phase_ends_at;
      this.acro           = data.acro;
      this.players        = [];
      angular.forEach(data.players, function(player){
        // initialize player object
        this.players.push(player);
      });
      this.winner         = data.winner;

      this.entries        = [];
      angular.forEach(data.entries, function(entry){
        // initialize entry object
        this.entries.push(entry);
      });
      this.results        = [];
      angular.forEach(data.results, function(result){
        // initialize result object
        this.entries.push(result);
      });
    }

    Game.prototype = {
      functionOne: function(){ console.log('test1') },
      functionTwo: function(){ console.log('test2') }
    };
    var resourceGame = $resource("/acro/api/v1/game",
      {  }
    );
    angular.extend(Game, resourceGame);
    return Game;
  }])
  .value('version', '0.1');

angular.module('acroApp.controllers', [])
  .controller('GameController', ['$scope', 'Game', '$log', function($scope, Game, $log) {

  }]);
// TODO: Implement your controllers, directives and services here

