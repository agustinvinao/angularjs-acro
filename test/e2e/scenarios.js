'use strict';

/* https://github.com/angular/protractor/blob/master/docs/getting-started.md */

describe('acro app', function() {
  browser.get('index.html');

  it('should show the game status', function() {
    expect(browser.getLocationAbsUrl()).toMatch("/");
    expect(element.all(by.css('.game-status')).first().getText()).toMatch(/There are currently (\d+) players online./);
  });


  it('should show the join form', function() {
    expect(browser.getLocationAbsUrl()).toMatch("/");
    expect(element('form[name="joinForm"]')).toBeDefined();
  });

  it('should have disabled the submit button', function() {
    expect(browser.getLocationAbsUrl()).toMatch("/");
    expect(element.all(by.css('input[type="submit"]')).first().getAttribute('disabled')).toBeTruthy();
  });

  it('should have enable the submit button when pick a handler', function() {
    expect(browser.getLocationAbsUrl()).toMatch("/");
    element(by.model('player.requestedName')).sendKeys('player');
    expect(element.all(by.css('input[type="submit"]')).first().getAttribute('disabled')).toBeFalsy();
  });
});