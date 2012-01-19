###
Geometry primitives and utilities
###

# truncate number to `precision` decimal places
Math.truncate = (x, precision = 0) ->
  scale = [1, 10, 100, 1000, 10000, 100000, 1000000][precision]
  Math.round(x * scale) / scale

Geom =
  # returns the angle formed by three points, in the range [-pi, pi]
  angle: (a, b, c) ->
    u = [b[0] - a[0], b[1] - a[1]]
    v = [c[0] - b[0], c[1] - b[1]]
    Math.atan2(u[0]*v[1] - v[0]*u[1], u[0]*v[0] + u[1]*v[1])

  # returns the point of intersection of line segments [u1, v1] and [u2, v2],
  # or `undefined` if given line segments do not intersect.
  intersect: (u1, v1, u2, v2) ->
    denom = (v1[0] - u1[0])*(v2[1] - u2[1]) - (v1[1] - u1[1])*(v2[0] - u2[0])
    if denom == 0 # line segments are parallel
      return undefined
    num1 = (u1[1] - u2[1])*(v2[0] - u2[0]) - (u1[0] - u2[0])*(v2[1] - u2[1])
    num2 = (u1[1] - u2[1])*(v1[0] - u1[0]) - (u1[0] - u2[0])*(v1[1] - u1[1])
    r = num1 / denom
    s = num2 / denom
    if 0 < r < 1 and 0 < s < 1
      return [u1[0] + r * (v1[0] - u1[0]), u1[1] + r * (v1[1] - u1[1])]
    else
      return undefined

# exports
(exports ? this).Geom = Geom
