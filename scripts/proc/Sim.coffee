# Simulation controller
class Sim
  constructor: (@timescale = 1.0) ->

  update: ->
    entity.Store.each entity.Position, entity.Velocity, (ent, position, velocity) =>
      remaining = velocity.v
      animation = undefined
      segment = undefined
      target = entity.Store.get(ent, entity.Repr).el
      to = (position, t) ->
        Raphael.animation {transform: 't' + position.toString()}, t, 'linear'
      while remaining > 0 && velocity.path.length > 0
        dist = Geom.dist(position, velocity.path[0])
        if remaining <= dist
          position[0] += (velocity.path[0][0] - position[0]) * remaining/dist
          position[1] += (velocity.path[0][1] - position[1]) * remaining/dist
        else
          position.replace(velocity.path.shift())
        t = @timescale * 1000 * Math.min(remaining, dist) / velocity.v
        if segment?
          # Add a continuation to the existing animation
          do (next = to(position, t)) ->
            segment.anim[100].callback = -> target.animate(next)
            segment = next
        else
          # First animation step
          animation = segment = to(position, t)
        remaining -= dist

      target.animate(animation) if animation?

# Exports
(exports ? @.proc ?= {}).Sim = Sim
