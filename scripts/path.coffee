
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

# Initialise entity store
store = entity.Store

# Initialise processes
path = new proc.Path(paper)
drag = new proc.Drag(paper)
drag.on 'update', -> path.update()

# Create entities
store.templates['actor'] = (pos) ->
  el = paper.circle(0.5, 0.5, 9)
            .attr
              'fill': 'yellow'
              'fill-opacity': 0.1
              'stroke': 'yellow'
              'stroke-width': 1.5
  store.from_components new entity.Position(pos), new entity.Repr(el, pos)

store.templates['sink'] = (pos) ->
  el = paper.circle(0.5, 0.5, 12)
            .attr
              'fill': 'white'
              'fill-opacity': 0.1
              'stroke': 'white'
              'stroke-dasharray': '- '
              'stroke-width': 1
  store.from_components new entity.Position(pos), new entity.Repr(el, pos)

store.templates['obstacle'] = (pos, poly...) ->
  el = paper.path("M#{poly[0]}L#{poly[1..].join('L')}L#{poly[0]}")
            .attr
              'fill': 'white'
              'fill-opacity': 0.1
              'stroke': 'white'
              'stroke-width': 1.5
  store.from_components new entity.Position(pos), new entity.Poly(poly), new entity.Repr(el, pos)

source = store.from_template 'sink', [100, 100]
sink = store.from_template 'sink', [400, 400]
a = store.from_template 'actor', [100, 100]
store.from_template 'obstacle', [100, 180], [0,0], [100,20], [50,50], [50,100], [-50,150], [20,100]
store.from_template 'obstacle', [250, 120], [0,0], [100,0], [0,140]
store.from_template 'obstacle', [170, 280], [0,0], [200,0], [200,50], [0,50]

path.update()
