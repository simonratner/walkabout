###
walkabout
###

paper = Raphael "paper", 500, 500

message = (text, x = paper.width / 2, y = 40) ->
  el = paper.text(x, y - 10, text).attr({'fill': '#fff', 'font': '12px Consolas'})
  oncomplete = ->
    this.remove()
  anim = Raphael.animation {
    'transform': 't0,-24'
    'opacity': 0
  }, 750, 'linear', oncomplete
  el.animate anim.delay(500)

class Base
  constructor: (@repr) ->
    @repr.drag @ondragmove, @ondragstart, @ondragend, this, this, this
    @repr.attr {
      'cursor': 'hand'
      'fill': 'white'
      'fill-opacity': 0.1
      'stroke': 'white'
      'stroke-width': 1.5
    }

  ondragstart: ->
    [@dragx, @dragy] = @offset

  ondragmove: (dx, dy) ->
    box = @bounds()
    @offset = [
      Math.min(Math.max(@dragx + dx, -box.x), paper.width - box.x - box.width)
      Math.min(Math.max(@dragy + dy, -box.y), paper.height - box.y - box.height)
    ]

  ondragend: ->
    @message @offset

  bounds: (transformed = false) ->
    @repr.getBBox(not transformed)

  message: (text) ->
    box = @bounds(true)
    message(text, box.x + box.width/2, box.y).attr('fill', @repr.attr('fill'))

  @get 'offset', ->
    transform = @repr.transform()[0]
    if transform then transform[1..2] else [0,0]

  @set 'offset', ([x, y]) ->
    @repr.transform ["t", x, y]
    eve "change"

class Actor extends Base
  constructor: (@r) ->
    super paper.circle 0, 0, @r
    @repr.attr {
      'fill': '#ff0'
      'stroke': '#ff0'
    }

class Obstacle extends Base
  constructor: (@poly...) ->
    super paper.path "M#{@poly[0]}L#{@poly[1..].join('L')}L#{@poly[0]}"
    @poly.forEach (p, i, poly) ->
      p.left = poly[(i-1 + poly.length) % poly.length]
      p.right = poly[(i+1) % poly.length]
      u = [p[0] - p.left[0], p[1] - p.left[1]]
      v = [p.right[0] - p[0], p.right[1] - p[1]]
      p.internal = Math.atan2(u[0]*v[1] - v[0]*u[1], u[0]*v[0] + u[1]*v[1]) <= 0

  @get 'vertices', ->
    offset = @offset
    translate = (p) ->
      t = [p[0] + offset[0], p[1] + offset[1]]
      t.left = [p.left[0] + offset[0], p.left[1] + offset[1]]
      t.right = [p.right[0] + offset[0], p.right[1] + offset[1]]
      t.internal = p.internal
      t
    @poly.map (p) -> translate p

### ###

a = new Actor(8)
a.offset = [100, 100]

obs = [
  new Obstacle [0,0], [100,20], [50,50], [50,100], [-50,150], [20,100]
  new Obstacle [0,0], [100,0], [0,140]
  new Obstacle [0,0], [200,0], [200,50], [0,50]
]
obs[0].offset = [100, 180]
obs[1].offset = [250, 100]
obs[2].offset = [170, 280]
#obs = [
  #new Obstacle [100,0], [100,100], [0,100]
  #new Obstacle [0,0], [100,0], [0,100]
#]
#obs[0].offset = [100, 100]
#obs[1].offset = [300, 300]
#obs = [
  #new Obstacle [0,0], [100,0], [0,140]
  ##new Obstacle [0,0], [200,0], [100,100], [200,200], [0,200]
#]
#obs[0].offset = [264, 122]

target = new Actor 15
target.offset = [400, 400]
target.repr.attr {
  'stroke-dasharray': '- '
  'stroke-width': 1
}

### ###

intersect = (u1, v1, u2, v2) ->
  denom = (v1[0] - u1[0])*(v2[1] - u2[1]) - (v1[1] - u1[1])*(v2[0] - u2[0])
  if denom == 0 # line segments are parallel
    #console.log u1, v1, "parallel to", u2, v2
    return undefined
  num1 = (u1[1] - u2[1])*(v2[0] - u2[0]) - (u1[0] - u2[0])*(v2[1] - u2[1])
  num2 = (u1[1] - u2[1])*(v1[0] - u1[0]) - (u1[0] - u2[0])*(v1[1] - u1[1])
  r = num1 / denom
  s = num2 / denom
  if 0 < r < 1 and 0 < s < 1
    #console.log u1, v1, "intersects", u2, v2
    return [u1[0] + r * (v1[0] - u1[0]), u1[1] + r * (v1[1] - u1[1])]
  else
    #console.log u1, v1, "misses", u2, v2
    return undefined

decorators = paper.set()
recalculate = ->
  decorators.forEach (i) -> i.remove() or true
  decorators.clear()
  vertices = []
  edges = []
  for o in obs
    vs = o.vertices
    vertices.push.apply vertices, vs
    edges.push.apply edges, [[v, v.left]] for v in vs

  links = []
  for u in vertices
    for v in vertices
      if u.internal or v.internal
        continue
      if (u[0] - v[0]) != 0
        m = (u[1] - v[1]) / (u[0] - v[0])
        y0 = -u[0] * m + u[1]
        y_u1 = Math.truncate(m * u.left[0] + y0, 6)
        y_u2 = Math.truncate(m * u.right[0] + y0, 6)
        y_v1 = Math.truncate(m * v.left[0] + y0, 6)
        y_v2 = Math.truncate(m * v.right[0] + y0, 6)
        if (y_u1 < u.left[1] and y_u2 > u.right[1]) or (y_u1 > u.left[1] and y_u2 < u.right[1])
          continue
        if (y_v1 < v.left[1] and y_v2 > v.right[1]) or (y_v1 > v.left[1] and y_v2 < v.right[1])
          continue
      else if (u[1] - v[1]) != 0
        if (u.left[0] < u[0] and u.right[0] > u[0]) or (u.left[0] > u[0] and u.right[0] < u[0])
          continue
        if (v.left[0] < v[0] and v.right[0] > v[0]) or (v.left[0] > v[0] and v.right[0] < v[0])
          continue
      else
        continue
      if edges.some((edge) -> intersect(edge[0], edge[1], u, v))
        continue
      links.push [u, v]

  console.log links.length / vertices.length / vertices.length # link density

  # draw them
  decorators.push.apply decorators, vertices.map (v) ->
    color = 'red' unless v.internal
    paper.circle(v[0], v[1], 5).attr {'stroke': 'none', 'fill': color, 'fill-opacity': 0.5}
  decorators.push paper.path(links.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'red', 'stroke-width': 2, 'stroke-opacity': 0.5}

eve.on "change", recalculate
recalculate()
