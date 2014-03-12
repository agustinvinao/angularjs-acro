'use strict';

/* https://github.com/angular/protractor/blob/master/docs/getting-started.md */

describe('acro app', function() {
  browser.get('index.html');
  var ptor = protractor.getInstance();
  describe('join game page', function(){
    beforeEach(function() {
      ptor.get('#/');
    });

    it('should load the join game page', function(){
      expect(
        ptor.findElement(protractor.By.css('.game-status')).getText()
      ).toMatch(/There are currently (\d+) players online./);
    });
    it('should show the join form', function() {
      expect(
        ptor.findElement(protractor.By.css('form[name="joinForm"]')).getText()
      ).toBeDefined();
    });

    it('should have disabled the submit button', function() {
      expect(
        ptor.findElement(protractor.By.css('input[type="submit"]')).getAttribute('disabled')
      ).toBeTruthy();
    });

    it('should have enable the submit button when pick a handler', function() {
      ptor.findElement(protractor.By.model('player.requestedName')).sendKeys('player');
      expect(
        ptor.findElement(protractor.By.css('input[type="submit"]')).getAttribute('disabled')
      ).toBeFalsy();
      ptor.findElement(protractor.By.css('input[type="submit"]')).click().then(function(){
        expect(ptor.getCurrentUrl()).toContain('#/main');
      });
    });
  });

  describe('main template', function(){
    beforeEach(function() {
      ptor.get('#/main');
    });
    it('should show the current acro to expand', function(){
      expect(
        ptor.findElement(protractor.By.css('.acro')).getText()
      ).toBeDefined();
    });

    it('should be the input to enter the expansive fr the acro', function(){
      var inputExpansion = ptor.findElement(protractor.By.model('player.suggestedExpansion'))
      expect(inputExpansion.isDisplayed()).toBe(true);
    });

    it('should show the phase name and time left', function(){
      var phase = ptor.findElement(protractor.By.css('.header.right'));
      expect(phase.getText()).toMatch(/Round \d+ play (ends|voting ends|begins) in \.\.\. \d+s/)
    });


  });

});