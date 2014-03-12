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
      'karma-jasmine',
      'karma-coverage'
    ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    },

    // coverage reporter generates the coverage
    reporters: ['progress', 'coverage'],

    preprocessors: {
      // source files, that you wanna generate coverage for
      // do not include tests or libraries
      // (these files will be instrumented by Istanbul)
      'public/javascripts/**/*.js': ['coverage']
    },

    // optionally, configure the reporter
    coverageReporter: {
      type : 'html',
      dir : 'coverage/'
    }

  })}