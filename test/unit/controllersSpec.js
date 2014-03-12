'use strict';

describe('controllers', function() {

  beforeEach(module('acroApp.controllers'));
  beforeEach(module('acroApp.services'));
  beforeEach(module('ngCookies'));

  var scope, ctrl, player, httpBackend, game, location;

  beforeEach(inject(function(_$httpBackend_, $controller, $rootScope, $location) {
    scope = $rootScope.$new();
    inject(function(_$httpBackend_, _Player_, _Game_){
      player      = _Player_;
      httpBackend = _$httpBackend_;
      game        = _Game_;
      location    = $location;
    });
    ctrl = $controller('GameController', {
      $scope: scope
    });

    var game_data = {"uuid":'239239',
      "round_number": 2,
      "phase": 'play',
      "phase_ends_at": '2013-10-01T11:01:35',
      "acro": 'TZFGH',
      "players": [
        { "uuid": '123', "name": 'BobSmith', "score": 8 },
        { "uuid": '345', "name": 'John Doe', "score": 10 }
      ],
      "winner": '345',
      "entries": [
        { "uuid": '239', "expansion": 'The skies are blue over Brooklyn'},
        { "uuid": '389', "expansion": 'Today, sky appears blue. Overly blue.'}
      ],
      "results": [
        { "player": '123', "votes": 1, "expansion": 'The skies are blueover Brooklyn' },
        { "player": '345', "votes": 2, "expansion": 'Today, sky appearsblue. Overly blue.' }
      ]
    }
    httpBackend.expectGET('/acro/api/v1/game?name=test').respond(200, game_data);
    scope.game = game.get({name: 'test'})
    httpBackend.flush();

    var player_data = {uuid: '123', name: 'Player'}
    httpBackend.expectPOST('/acro/api/v1/player').respond(200, player_data);
    scope.player = player.joinGame({name: 'Player'});
    httpBackend.flush();
  }));

  it ('should have have the templates functions', inject(function(){
    // this are all the functions acccesed from templates
    expect(scope.secondsLeft).toBeDefined();
    expect(scope.roundNumber).toBeDefined();
    expect(scope.submitEntry).toBeDefined();
    expect(scope.playerHasVoted).toBeDefined();
    expect(scope.submitVote).toBeDefined();
    expect(scope.joinGame).toBeDefined();
  }));

  it ('should have test game data in server', inject(function(){
    expect(scope.game).toBeDefined();
    expect(scope.roundNumber()).toBe(2);
  }));

  it('should check if the player has voted', inject(function(){
    scope.player = {uuid: '23432', name: 'Foobar', score: 0};
    expect(scope.playerHasVoted()).toBeFalsy();
  }));

  it('should submit a vote from the player', inject(function(){
    scope.submitVote();
    expect(scope.player.voted).toBeTruthy();
  }));

  it('should submit an entry', inject(function(){
    httpBackend.expectPOST('/acro/api/v1/player/123/entry').respond(201, { uuid: '23392', acro: 'TZFGU', expansion: 'Traditionally, Zombies Feel Great Undead', received_at: '2013-10-01T11:09:38', accepted: true });
    scope.submitEntry();
    httpBackend.flush();
    expect(scope.player.entry).toBeDefined();
  }));

  it('should join game', inject(function(){
    httpBackend.expectPOST('/acro/api/v1/player').respond(200, {uuid: '123', name: 'Player'});
    scope.joinGame();
    httpBackend.flush();
    expect(location.path()).toEqual('/main');
  }));

});