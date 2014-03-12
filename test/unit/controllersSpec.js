'use strict';

describe('controllers', function() {

  beforeEach(module('acroApp.controllers'));
  beforeEach(module('acroApp.services'));

  var scope, ctrl;

  beforeEach(inject(function(_$httpBackend_, $controller, $rootScope) {
    scope = $rootScope.$new();
    ctrl = $controller('GameController', {
      $scope: scope
    });

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
    scope.game = {uuid: '239239', round_number: 2, phase: 'play', phase_ends_at: '2013-10-01T11:01:35', acro: 'TZFGU'};
    expect(scope.game).toBeDefined();
    expect(scope.roundNumber()).toBe(2);
  }));
  it('should check if the player has voted', inject(function(){
    scope.player = {uuid: '23432', name: 'Foobar', score: 0};
    expect(scope.playerHasVoted()).toBeFalsy();
  }));

});