# Entity position
class Position
  constructor: (@position) ->

# Exports
(exports ? @ ? window).entity ?= {}
(exports ? @ ? window).entity.Position = Position
