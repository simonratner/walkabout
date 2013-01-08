# Position
class Position extends Array
  constructor: (position) ->
    @replace(position)

  replace: (position) ->
    @length = 0
    @push.apply(@, position)

# Exports
(exports ? @.entity ?= {}).Position = Position
