expect = require("chai").expect
Color = require("color")
ColorMatcher = require("../src/RecolorSvg").ColorMatcher

describe "ColorMatcher", () ->

  it "should return truthy for two identical colors", () ->
    matcher = ColorMatcher("blue")
    expect(matcher("blue")).to.be.true

  it "should return falsy for two different colors", () ->
    matcher = ColorMatcher("white")
    expect(matcher("black")).to.be.false

  it "should respect the maxDifference property, if specified", () ->
    firstColor = "#888"
    secondColor = "#999"

    strictMatcher = ColorMatcher(firstColor, 0)
    expect(strictMatcher(secondColor)).to.be.false

    permissiveMatcher = ColorMatcher(firstColor, 100)
    expect(permissiveMatcher(secondColor)).to.be.true
