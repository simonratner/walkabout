###
Geometry primitives and utilities
###

# truncate number to `precision` decimal places
Math.truncate = (x, precision = 0) ->
  scale = [1, 10, 100, 1000, 10000, 100000, 1000000][precision]
  Math.round(x * scale) / scale
