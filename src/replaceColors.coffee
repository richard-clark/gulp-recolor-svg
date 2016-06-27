cheerio = require("cheerio")
Color = require("color")
css = require("css")

module.exports = (stringData, matchers, destColors) ->
  $ = cheerio.load stringData,
    xmlMode: true

  propertiesToReplace = ["fill", "stroke"]

  getNewColor = (stringColorValue) ->
    if stringColorValue isnt "none"
      color = Color(stringColorValue)
      outputColor = stringColorValue

      for matcher, index in matchers
        if matcher(color)
          outputColor = destColors[index].hexString()

      return outputColor

  handleStyleSheet = (element) ->
    stringData = element.text()
    data = css.parse(stringData, {})
    for rule in data.stylesheet.rules
      for declaration in rule.declarations when declaration.property in propertiesToReplace
        declaration.value = getNewColor(declaration.value)

    element.text(css.stringify(data, {}))

  $("style").each (index, element) ->
    handleStyleSheet($(element))

  for propertyToReplace in propertiesToReplace
    $("[#{propertyToReplace}]").each (index, _element) ->
      element = $(_element)
      element.attr(propertyToReplace, getNewColor(element.attr(propertyToReplace)))

  return $.xml()
