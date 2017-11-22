expect = require("chai").expect
RecolorSvg = require("../src/RecolorSvg")
File = require("vinyl")

wrapAsSvg = (text) ->
  '<?xml version="1.0" encoding="utf-8"?><svg>' + text + '</svg>'

SimpleMatcher = (firstColor) ->
  [r1, g1, b1] = firstColor.rgb().array()
  (secondColor) ->
    [r2, g2, b2] = secondColor.rgb().array()
    return r1 is r2 and g1 is g2 and b1 is b2

getStreamOutput = (stream, callback) ->
  output = []

  stream.on "data", (data) ->
    output.push(data)

  stream.on "end", () ->
    callback(output)

describe "RecolorSvg", () ->

  describe "Replace", () ->

    it "should replace an input color and emit a file", (done) ->
      fakeFile = new File
        contents: new Buffer(wrapAsSvg('<path fill="red"/>'), "utf8")

      stream = RecolorSvg.Replace(
        [SimpleMatcher(RecolorSvg.Color("red"))],
        [RecolorSvg.Color("blue")]
      )
      stream.write(fakeFile)

      stream.once "data", (file) ->
        actualOutput = file.contents.toString()

        expect(actualOutput).to.equal(wrapAsSvg('<path fill="#0000FF"/>'))

        done()

  describe "GenerateVariants", () ->

    it "should replace an input color and emit multiple files", (done) ->
      fakeFile = new File
        path: "foo/bar/baz.svg"
        contents: new Buffer(wrapAsSvg('<path fill="red"/>'), "utf8")

      stream = RecolorSvg.GenerateVariants(
        [SimpleMatcher(RecolorSvg.Color("red"))],
        [
            suffix: "--lime"
            colors: [RecolorSvg.Color("lime")]
          ,
            suffix: "--blue"
            colors: [RecolorSvg.Color("blue")]
        ]
      )
      stream.write(fakeFile)
      stream.end()

      getStreamOutput stream, (files) ->
        expect(files.length).to.equal(2)

        [firstFile, secondFile] = files

        expect(firstFile.contents.toString()).to.equal(wrapAsSvg('<path fill="#00FF00"/>'))
        expect(firstFile.path).to.equal("foo/bar/baz--lime.svg")

        expect(secondFile.contents.toString()).to.equal(wrapAsSvg('<path fill="#0000FF"/>'))
        expect(secondFile.path).to.equal("foo/bar/baz--blue.svg")

        done()
