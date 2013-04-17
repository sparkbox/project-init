testingSteps = ->
    
  this.Given /^grunt is running$/, (callback) ->
    # express the regexp above with the code you wish you had
    callback.pending()

  this.Then /^I can run tests$/, (callback) ->
    # express the regexp above with the code you wish you had
    callback.pending()
    
module.exports = testingSteps