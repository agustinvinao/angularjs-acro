angularjs-acro
==============

This is a very simple game named Acro


Run Tests:
=========

## Unit tests:

Karma config resides in config/karma.conf.js, is not necessary change any config.
To run unit tests you can :

```
./scripts/test.sh
```

if you have your karma bin file in a different location ($BASE_DIR/../node_modules/karma/bin/karma) it's recommend to
create a new .sh file and include it in gitignore file.

As an example of this case you can check scripts/mytest.sh

## E2E tests:

We use Protactor to do E2E test, to run this you'll need your server running and confirm your app port in config/protactor-conf.js

If you run your app with rackup it should use port 9292 as default, protactor is configured to use that port.

To run e2e tests you can use:

```
./scripts/e2e-test.sh
```

if you have your karma bin file in a different location ($BASE_DIR/../node_modules/protractor/bin/protractor) it's recommend to
create a new .sh file and include it in gitignore file.

As an example of this case you can check scripts/my-e2e-test.sh


## Main view:

THis view has some functions defined to call directly. For example, the line when it says about the round Number it calls
a function defined in the controller.
In some cases it can be called directly from the game model object.

