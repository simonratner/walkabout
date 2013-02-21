
paper = Raphael "paper", 501, 501

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
drag = new proc.Drag(paper)
path = new proc.Path(paper)
sim = new proc.Sim()

# Create entities
store.templates['actor'] = (pos, sink) ->
  el = paper.circle(0.5, 0.5, 9)
            .attr
              'fill': '#6699ff'
              'fill-opacity': 0.1
              'stroke': '#6699ff'
              'stroke-width': 1.5
  store.from_components new entity.Position(pos), new entity.Repr(el, pos), new entity.Velocity(100.0, [sink])

store.templates['sink'] = (pos) ->
  el = paper.circle(0.5, 0.5, 12)
            .attr
              'fill': '#6699ff'
              'fill-opacity': 0.1
              'stroke': '#6699ff'
              'stroke-dasharray': '- '
              'stroke-width': 1
  store.from_components new entity.Position(pos), new entity.Repr(el, pos)

store.templates['obstacle'] = (pos, poly...) ->
  el = paper.path("M#{poly[0]}L#{poly[1..].join('L')}L#{poly[0]}")
            .attr
              'fill': '#999999'
              'fill-opacity': 0.1
              'stroke': '#999999'
              'stroke-width': 1.5
  store.from_components new entity.Position(pos), new entity.Poly(poly), new entity.Repr(el, pos)

sink = store.from_template 'sink', [400, 400]
actor = store.from_template 'actor', [100, 100], [400, 400]
store.from_template 'obstacle', [110, 180], [0,0], [100,20], [50,50], [50,90], [-50,160], [20,100]
store.from_template 'obstacle', [250, 120], [0,0], [60,0], [0,140]
store.from_template 'obstacle', [180, 300], [0,0], [200,0], [200,50], [0,50]

drag.on 'update', (ent, offset) ->
  if ent == sink
    store.get(actor, entity.Velocity).waypoints = [offset]
  path.update()

path.update()

document.getElementById('step').onclick = ->
  sim.update()
  path.update()
