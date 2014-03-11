'use strict';

/* https://github.com/angular/protractor/blob/master/docs/getting-started.md */

describe('acro app', function() {

  browser.get('index.html');

  it('should show the join form', function() {
    expect(browser.getLocationAbsUrl()).toMatch("/");
    expect(element('form[name="joinForm"]')).toBeDefined();
  });

});