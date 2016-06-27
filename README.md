# Recolor SVG

A gulp package for replacing colors within SVGs.

## Example

Consider the following SVG—named ``plus.svg``, it represents a blue "+" symbol:

```xml
<?xml version="1.0" encoding="utf-8"?>
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 15 15" enable-background="new 0 0 15 15" xml:space="preserve">
	<path fill="#0000FF" d="M6.3,1.1v5.2H1.1c-0.7,0-0.7,0.5-0.7,1.2c0,0.7,0.1,1.2,0.7,1.2h5.2v5.2c0,0.7,0.5,0.7,1.2,0.7
		c0.7,0,1.2-0.1,1.2-0.7V8.7h5.2c0.7,0,0.7-0.5,0.7-1.2c0-0.7-0.1-1.2-0.7-1.2H8.7V1.1c0-0.7-0.5-0.7-1.2-0.7
		C6.8,0.4,6.3,0.5,6.3,1.1"/>
</svg>
```

### Simple Recolor

The following is an example of creating a red version of this icon:

```coffeescript
Color = require("color")
gulp = require("gulp")
RecolorSvg = require("./RecolorSvg")

gulp.task "default", () ->
	gulp.src("plus.svg")
		.pipe(RecolorSvg.Replace(
			[ RecolorSvg.ColorMatcher(Color("0000FF")) ],
			[ Color("FF0000") ]))
		.pipe(gulp.dest("plus--red.svg"))
```

When ``gulp`` is run, it will generate a new SVG, ``plus--reg.svg``, containing a red plus icon in place of the blue SVG.

### Generating Multiple Variants

Recolor SVG also provides another function for generating multiple variants from a single input. For example, If we wish to use the plus icon as the background of an image, we can generate varints for hover, active, focus, and disabled button states. We can do this with the following gulp task:

```coffeescript
Color = require("color")
gulp = require("gulp")
RecolorSvg = require("./RecolorSvg")

gulp.task "default", () ->
	gulp.src("plus.svg")
		.pipe(RecolorSvg.GenerateVariants(
			[ RecolorSvg.ColorMatcher(Color("#0000FF")) ],
			[
					suffix: "--hover"
					colors: [ Color("red") ]
				,
					suffix: "--active"
					colors: [ Color("red").darken(0.1) ]
				,
					suffix: "--focus"
					colors: [ Color("cyan") ]
				,
					suffix: "--disabled"
					colors: [ Color("gainsboro") ]
			]
		))
		.pipe(gulp.dest("./"))
```

When this task is run, it will generate four SVGs: ``plus--hover.svg``, ``plus--active.svg``, ``plus--focus.svg``, and ``plus--disabled.svg``, each with a different color.

## API

### Color(args...)

This is just a wrapper around the [color](https://github.com/qix-/color) package for Node, which provides utilities for parsing and serializing CSS colors.

### ColorMatcher(colorToMatch, [maxDifference=0.1])

This returns a function that, when invoked with a color, will return a boolean value indicating whether the similarity of this color to the color used when instantiating the matcher is within the specified threshold.

Colors are compared using the [CIE76 color difference algorithm](https://en.wikipedia.org/wiki/Color_difference). Since the vision of humans is more sensitive to differences in certain colors than in others, using the algorithm allows colors to be replaced uniformly across the visible spectrum. (However, this algorithm does have certain limitations—see the linked algorithm.)

Usage:

```
{ Color, ColorMatcher } = require("./RecolorSvg")

matcher = RecolorSvg.ColorMatcher(Color("red"), 2)

matcher(Color("red").lighten(0.02)) # returns true
matcher(Color("blue")) # returns false
```

### GenerateVariants(matcherFunctions, variants)

Returns a function that when passed a stream containing a file, emits multiple files—one for each variant—with the colors replaced.

Arguments:

- ``matcherFunctions`` is an array of functions that accept a single argument (a color) and return a boolean value indicating whether that color should be replaced. A matcher function can be an instance of ``ColorMatcher``, or a custom function.

- ``variants``: an array of objects with ``suffix`` and ``colors`` properties. The value of ``suffix`` is appended to the file name of the file generated for the variant; the value of ``colors`` is an array of colors, with a length equal to the length of ``matcherFunctions``. If a function from ``matcherFunctions`` evaluates to ``true`` for a certain color in the SVG, that color will be replaced with the color at the corresponding index from ``colors``.

### Replace(matcherFunctions, replacementColors)

Returns a function that when passed a stream containing a file, emits a file with the colors replaced.

Arguments:

- ``matcherFunctions`` is an array of functions that accept a single argument (a color) and return a boolean value indicating whether that color should be replaced. A matcher function can be an instance of ``ColorMatcher``, or a custom function.

- ``replacementColors`` is an array of replacement colors. The length of this array should match the length of ``matcherFunctions``. For each function of ``matcherFunction``, if the function returns a ``true`` value, that color will be replaced by the color at the corresponding index from ``replacementColors``.

See the [Simple Recolor] example.

## Limitations

Currently, Recolor SVG will change the value of ``fill`` and ``stroke`` properties set as attributes on SVG elements, or in embedded stylesheets. It does not currently work with other properties, nor does it currently support transparency.
