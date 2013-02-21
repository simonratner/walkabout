# Simulation controller
class Sim
  constructor: (@timescale = 1.0) ->

  update: ->
    entity.Store.each entity.Position, entity.Velocity, (ent, position, velocity) =>
      d = velocity.v
      while d > 0 && velocity.path.length > 0
        dist = Geom.dist(position, velocity.path[0])
        if d <= dist
          position[0] += (velocity.path[0][0] - position[0]) * d/dist
          position[1] += (velocity.path[0][1] - position[1]) * d/dist
        else
          position.replace(velocity.path.shift())
        d -= dist
      anim = Raphael.animation {
        'transform': 't' + position.toString()
      }, @timescale * 1000, 'linear'
      entity.Store.get(ent, entity.Repr).el.animate anim

# Exports
(exports ? @.proc ?= {}).Sim = Sim
