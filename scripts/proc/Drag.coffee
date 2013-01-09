# Drag process: drag things around
class Drag
  constructor: (paper) ->
    smokesignals.convert(@)
    emit = @emit
    entity.Store.on 'added/Repr', (ent, component) ->
      dragx = undefined
      dragy = undefined
      dragstart = ->
        [dragx, dragy] = @offset
        emit('start')
      dragend = ->
        dragx = undefined
        dragy = undefined
        emit('end')
      dragmove = (dx, dy) ->
        box = @bounds()
        @offset = offset = [
          Math.min(Math.max(dragx + dx, -box.x), paper.width - box.x - box.width)
          Math.min(Math.max(dragy + dy, -box.y), paper.height - box.y - box.height)
        ]
        entity.Store.get(ent, entity.Position)?.replace(offset)
        emit('update', ent, offset)
      component.el.drag dragmove, dragstart, dragend, component, component, component
      component.el.attr {
        'cursor': 'hand'
      }

# Exports
(exports ? @.proc ?= {}).Drag = Drag
