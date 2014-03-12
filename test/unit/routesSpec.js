'use strict';

describe('controllers', function() {

  beforeEach(module('acroApp'));

  var $httpBackend;

  beforeEach(inject(function(_$httpBackend_) {
    $httpBackend = _$httpBackend_;
    $httpBackend.expectGET('/acro/api/v1/game?name=test').respond(200,{uuid: '239239', round_number: 2, phase: 'play', phase_ends_at: '2013-10-01T11:01:35',
    acro: 'TZFGU'});
    $httpBackend.expectGET('/templates/main.html').respond(200, '<div></div>');
  }));


  it('should have a working /main route', inject(function($location, $rootScope, $route){
    $location.path('/main');
    $rootScope.$digest();

    expect($location.path()).toBe('/main');
    expect($route.current.controller).toBe('GameController');
  }));
});