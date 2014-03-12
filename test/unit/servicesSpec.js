'use strict';

describe('service', function() {
  beforeEach(module('ngCookies', 'acroApp.services'));

  describe('version', function() {
    it('should return current version', inject(function(version) {
      expect(version).toEqual('0.1');
    }));
  });

  describe('Player', function(){
    var player, cookies, httpBackend, name, uuid, current_player;
    beforeEach(function(){
      inject(function(_$httpBackend_, _Player_, _$cookies_){
        cookies     = _$cookies_;
        player      = _Player_;
        httpBackend = _$httpBackend_;
      });
      name = 'Player'; uuid = '23432';
      httpBackend.expectPOST('/acro/api/v1/player').respond(201, {"uuid":uuid,"name": name});
      current_player = player.joinGame({name: 'Player'});
      httpBackend.flush();
    })
    it('shoudl update the player data', function(){
      expect(current_player.uuid).toEqual(uuid);
      expect(current_player.name).toEqual(name);
    });

    it('should update the player info', function(){
      var data = {"uuid":'123456',"name": 'Player'};
      current_player.updateInfo(data);
      expect(current_player.uuid).toEqual('123456');
    });

    it('should serialize the player data', function(){
      var json_player = current_player.serialize();
      expect(json_player).toEqual(angular.toJson(current_player));
    });

    it('should set the player entry', function(){
      var entry = 'test';
      current_player.setCurrentEntry(entry);
      expect(current_player.entry).toEqual(entry);
    });
  });

  describe('Game', function(){
    var game, cookies, httpBackend, current_game, game_data;
    beforeEach(function(){
      inject(function(_$httpBackend_, _Game_, _$cookies_){
        cookies     = _$cookies_;
        game        = _Game_;
        httpBackend = _$httpBackend_;
      });
      game_data = {"uuid":'239239',
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
      current_game = game.get({name: 'test'})
      httpBackend.flush();
    })

    it('should add a new player to the game', function(){
      var player = { "uuid": '678', "name": 'John Smith', "score": 5 };
      current_game.addPlayer(player);
      expect(current_game.players.length).toBe(3);
    });

    it('should check if a player is in the game', function(){
      expect(current_game.hasPlayer('123')).toBeTruthy();
      expect(current_game.hasPlayer('789')).toBeFalsy();
    });

    it('should update game info', function(){
      var _game_data = {};
      angular.copy(game_data, _game_data);
      _game_data.round_number = 3;
      current_game.updateInfo(_game_data);
      expect(current_game.round_number).toBe(3);
    });


  });
});


