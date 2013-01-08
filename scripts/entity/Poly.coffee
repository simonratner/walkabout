# Polygon
class Poly extends Array
  constructor: (poly) ->
    @replace(poly)

  replace: (poly) ->
    @length = 0
    poly.forEach (v, i, poly) =>
      v.left = poly[(i-1 + poly.length) % poly.length]
      v.right = poly[(i+1) % poly.length]
      v.internal = Geom.angle(v.left, v, v.right) <= 0
      @push v

# Exports
(exports ? @.entity ?= {}).Poly = Poly
