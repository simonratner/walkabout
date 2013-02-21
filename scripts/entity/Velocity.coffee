# Velocity
class Velocity
  constructor: (@v, @waypoints = null) ->
    @path ?= []
    @waypoints ?= []

# Exports
(exports ? @.entity ?= {}).Velocity = Velocity
