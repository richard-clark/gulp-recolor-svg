Color = require("color")
ColorMatcher = require("./ColorMatcher")
gutil = require("gulp-util")
path = require("path")
replaceColors = require("./replaceColors")
through = require("through2")
File = require("vinyl")

Replace = (colorMatchers, colors) ->
  through.obj (file, encoding, callback) ->
    data = file.contents
    outputData = replaceColors(data, colorMatchers, colors)
    outputFile = new gutil.File
      cwd: file.cwd
      base: file.base
      path: file.path
      contents: new Buffer(outputData, "utf8")
    @push(outputFile)
    callback()

GenerateVariants = (colorMatchers, variants=[]) ->
  through.obj (file, encoding, callback) ->
    for variant in variants
      data = file.contents
      outputData = replaceColors(data, colorMatchers, variant.colors)

      baseName = path.basename(file.path)
      extension = path.extname(baseName)
      fileName = baseName.substr(0, baseName.length - extension.length)
      fileNameWithSuffix = fileName + variant.suffix + extension

      outputFile = new gutil.File
        cwd: file.cwd
        base: file.base
        path: path.join(path.dirname(file.path), fileNameWithSuffix)
        contents: new Buffer(outputData, "utf8")
      @push(outputFile)

    callback()

module.exports = {
  Color
  ColorMatcher
  Replace
  GenerateVariants
}
