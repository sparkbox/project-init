describe "This App", ->

  beforeEach ->
    affix "#element-id"

  it "should find the app files", ->
    expect( typeof APP ).toEqual "object"

  it "should find #element-id", ->
    expect( $( "#element-id" ).length ).toEqual 1
