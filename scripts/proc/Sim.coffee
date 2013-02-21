# Simulation controller
class Sim
  constructor: (@timescale = 1.0) ->

  update: ->
    entity.Store.each entity.Position, entity.Velocity, (ent, position, velocity) =>
      remaining = velocity.v
      path = 'M' + position.toString()
      while remaining > 0 && velocity.path.length > 0
        dist = Geom.dist(position, velocity.path[0])
        if remaining <= dist
          position[0] += (velocity.path[0][0] - position[0]) * remaining/dist
          position[1] += (velocity.path[0][1] - position[1]) * remaining/dist
        else
          position.replace(velocity.path.shift())
        path += 'L' + position.toString()
        remaining -= dist

      t = @timescale * 1000 *
        if 0 < remaining < velocity.v
          (velocity.v - remaining) / velocity.v
        else 1.0
      target = entity.Store.get(ent, entity.Repr).el
      target.animateAlong({guide: path}, t, 'linear')

# Exports
(exports ? @.proc ?= {}).Sim = Sim
