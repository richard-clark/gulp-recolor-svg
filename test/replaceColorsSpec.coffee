expect = require("chai").expect
Color = require("color")
replaceColors = require("../src/replaceColors")

wrapAsSvg = (text) ->
  '<?xml version="1.0" encoding="utf-8"?><svg>' + text + '</svg>'

identity = (val) ->
  () ->
    val

extractStylesheet = (input) ->
  input.replace(/\n/g, "")
    .match(/<style>(.*)<\/style>/)[1]
    .replace(/\s/g, "")

describe "replaceColors", () ->

  it "should not replace a fill attribute if the matcher returns false", () ->
    input = wrapAsSvg('<path fill="red"/>')
    expectedOutput = wrapAsSvg('<path fill="red"/>')
    actualOutput = replaceColors(input, [ identity(false) ], [ new Color("blue") ])
    expect(actualOutput).to.equal(expectedOutput)

  it "should replace a fill attribute", () ->
    input = wrapAsSvg('<path fill="red"/>')
    expectedOutput = wrapAsSvg('<path fill="#0000FF"/>')
    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    expect(actualOutput).to.equal(expectedOutput)

  it "should replace a stroke attribute", () ->
    input = wrapAsSvg('<path stroke="red"/>')
    expectedOutput = wrapAsSvg('<path stroke="#0000FF"/>')
    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    expect(actualOutput).to.equal(expectedOutput)

  it "should replace fill and stroke properties in a style attribute", () ->
    input = wrapAsSvg('<path style="stroke:red; fill: red; "/>')
    expectedOutput = wrapAsSvg('<path style="stroke:#0000FF;fill:#0000FF;"/>')
    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    expect(actualOutput).to.equal(expectedOutput)

  it "should replace fill and stroke properties in a style attribute without a
  leading semicolon", () ->
    input = wrapAsSvg('<path style="stroke:red; fill: red "/>')
    expectedOutput = wrapAsSvg('<path style="stroke:#0000FF;fill:#0000FF;"/>')
    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    expect(actualOutput).to.equal(expectedOutput)

  it "should replace a fill property in a style sheet", () ->
    input = wrapAsSvg('<style>path{fill:red}</style>')
    expectedStylesheet = "path{fill:#0000FF;}"

    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    actualStylesheet = extractStylesheet(actualOutput)
    expect(actualStylesheet).to.equal(expectedStylesheet)

  it "should replace a stroke property in a style sheet", () ->
    input = wrapAsSvg('<style>path{stroke:red}</style>')
    expectedStylesheet = "path{stroke:#0000FF;}"

    actualOutput = replaceColors(input, [ identity(true) ], [ new Color("blue") ])
    actualStylesheet = extractStylesheet(actualOutput)
    expect(actualStylesheet).to.equal(expectedStylesheet)
