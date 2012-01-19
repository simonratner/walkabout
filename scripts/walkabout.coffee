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
      p.internal = Geom.angle(p.left, p, p.right) <= 0

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

start = new Actor(8)
start.offset = [100, 100]

obs = [
  new Obstacle [0,0], [100,20], [50,50], [50,100], [-50,150], [20,100]
  new Obstacle [0,0], [100,0], [0,140]
  new Obstacle [0,0], [200,0], [200,50], [0,50]
]
obs[0].offset = [100, 180]
obs[1].offset = [250, 120]
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

end = new Actor 15
end.offset = [400, 400]
end.repr.attr {
  'stroke-dasharray': '- '
  'stroke-width': 1
}

### ###

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

  # build network
  links = []
  for u in vertices
    for v in vertices
      if u.internal or v.internal
        continue
      if (u[0] - v[0]) != 0
        [m, y0] = Geom.line(u, v)
        y_u1 = Math.round_to(m * u.left[0] + y0, 6)
        y_u2 = Math.round_to(m * u.right[0] + y0, 6)
        y_v1 = Math.round_to(m * v.left[0] + y0, 6)
        y_v2 = Math.round_to(m * v.right[0] + y0, 6)
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
      if edges.some((edge) -> Geom.intersect(edge[0], edge[1], u, v))
        continue
      links.push [u, v]

  # anchor start and end nodes
  anchors = []
  for u in [start.offset, end.offset]
    for v in vertices
      if (u[0] - v[0]) != 0
        [m, y0] = Geom.line(u, v)
        y_v1 = Math.round_to(m * v.left[0] + y0, 6)
        y_v2 = Math.round_to(m * v.right[0] + y0, 6)
        if (y_v1 < v.left[1] and y_v2 > v.right[1]) or (y_v1 > v.left[1] and y_v2 < v.right[1])
          continue
      else if (u[1] - v[1]) != 0
        if (v.left[0] < v[0] and v.right[0] > v[0]) or (v.left[0] > v[0] and v.right[0] < v[0])
          continue
      else
        continue
      if edges.some((edge) -> Geom.intersect(edge[0], edge[1], u, v))
        continue
      anchors.push [u, v]

  console.log links.length / vertices.length / vertices.length # link density

  # draw them
  decorators.push.apply decorators, vertices.map (v) ->
    color = 'red' unless v.internal
    paper.circle(v[0], v[1], 5).attr {'stroke': 'none', 'fill': color, 'fill-opacity': 0.5}
  decorators.push paper.path(links.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'red', 'stroke-width': 2, 'stroke-opacity': 0.5}
  decorators.push paper.path(anchors.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'yellow', 'stroke-width': 2, 'stroke-opacity': 0.5}

eve.on "change", recalculate
recalculate()
