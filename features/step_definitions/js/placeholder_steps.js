(function() {
  var testingSteps;

  testingSteps = function() {
    this.Given(/^grunt is running$/, function(callback) {
      return callback.pending();
    });
    return this.Then(/^I can run tests$/, function(callback) {
      return callback.pending();
    });
  };

  module.exports = testingSteps;

}).call(this);
