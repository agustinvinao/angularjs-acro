module.exports = function(config){
  config.set({
    basePath : '../',

    files : [
      'public/vendor/angularjs/angular.js',
      'public/vendor/angularjs/angular-*.js',
      'public/vendor/angularjs/angular-mocks.js',
      'public/javascripts/**/*.js',
      'test/unit/**/*.js'
    ],

    exclude : [
      'public/vendor/angularjs/angular-loader.js',
      'public/vendor/angularjs/*.min.js',
      'public/vendor/angularjs/angular-scenario.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['Chrome'],

    plugins : [
      'karma-junit-reporter',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-jasmine'
    ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }

  })}