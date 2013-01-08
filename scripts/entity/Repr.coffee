# Visual representation
class Repr
  constructor: (@el, @offset) ->

  bounds: (transformed = false) ->
    @el.getBBox(not transformed)

  @getattr offset: ->
    transform = @el.transform()[0]
    if transform then transform[1..2] else [0, 0]

  @setattr offset: ([x, y]) ->
    @el.transform ["t", x, y]

# Exports
(exports ? @.entity ?= {}).Repr = Repr
