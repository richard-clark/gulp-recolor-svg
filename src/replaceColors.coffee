cheerio = require("cheerio")
Color = require("color")
css = require("css")

INLINE_PROPERTY_MATCHER = /^\s*([^:\s]+)\s*:\s*(.*?)\s*$/
SPECIAL_PAINT_TYPES = ["none", "currentcolor", "inherit"]

parseInlineStyleSheet = (inlineStyle) ->
  inlineStyle.split(";")
    .map (rawProperty) ->
      rawProperty.match(INLINE_PROPERTY_MATCHER)
    .filter (match) ->
      match?
    .map ([..., property, value]) ->
      { property, value }

stringifyInlineStyleSheet = (declarations) ->
  return "" unless declarations.length > 0

  declarations.map ({ property, value }) ->
    "#{property}:#{value}"
  .concat("") # For trailing semicolon.
  .join(";")

module.exports = (stringData, matchers, destColors) ->
  $ = cheerio.load stringData,
    { xmlMode: true }

  propertiesToReplace = ["fill", "stroke"]

  getNewColor = (stringColorValue) ->
    if stringColorValue.toLowerCase() in SPECIAL_PAINT_TYPES
      return stringColorValue

    color = Color(stringColorValue)
    outputColor = stringColorValue

    for matcher, index in matchers
      if matcher(color)
        outputColor = Color(destColors[index]).hex()

    return outputColor

  replacePropertiesInDeclarations = (declarations) ->
    for declaration in declarations when declaration.property in propertiesToReplace
      declaration.value = getNewColor(declaration.value)

  handleStyleSheet = (element) ->
    stringData = element.text()
    data = css.parse(stringData, {})
    for rule in data.stylesheet.rules
      replacePropertiesInDeclarations(rule.declarations)
    outputData = css.stringify data,
      { compress: true }
    element.text(outputData)

  $("style").each (index, element) ->
    handleStyleSheet($(element))

  $("[style]").each (index, _element) ->
    element = $(_element)
    inlineStyle = element.attr("style")
    data = parseInlineStyleSheet(inlineStyle)
    replacePropertiesInDeclarations(data)
    outputData = stringifyInlineStyleSheet(data)
    element.attr("style", outputData)

  for propertyToReplace in propertiesToReplace
    $("[#{propertyToReplace}]").each (index, _element) ->
      element = $(_element)
      element.attr(propertyToReplace, getNewColor(element.attr(propertyToReplace)))

  return $.xml()
