(function() {

  describe("This App", function() {
    beforeEach(function() {
      return affix("#element-id");
    });
    it("should find the app files", function() {
      return expect(typeof APP).toEqual("object");
    });
    return it("should find #element-id", function() {
      return expect($("#element-id").length).toEqual(1);
    });
  });

}).call(this);
