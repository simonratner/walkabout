# Path process: pathfinding
class Path
  constructor: (@paper) ->
    @decorators = @paper.set()

  clear: ->
    @decorators.forEach (i) -> i.remove() or true
    @decorators.clear()

  update: ->
    vertices = []
    edges = []
    entity.Store.each entity.Position, entity.Poly, (ent, pos, poly) =>
      for v in poly
        v_prime = [v[0] + pos[0], v[1] + pos[1]]
        v_prime.left = [v.left[0] + pos[0], v.left[1] + pos[1]]
        v_prime.right = [v.right[0] + pos[0], v.right[1] + pos[1]]
        v_prime.internal = v.internal
        vertices.push v_prime
        edges.push [v_prime, v_prime.left]

    # build network
    links = []
    for u in vertices
      for v in vertices
        if u.internal or v.internal
          continue
        if (u[0] - v[0]) != 0
          [m, y0] = Geom.line(u, v)
          y_u1 = Math.round_to(m * u.left[0] + y0, 6)
          y_u2 = Math.round_to(m * u.right[0] + y0, 6)
          y_v1 = Math.round_to(m * v.left[0] + y0, 6)
          y_v2 = Math.round_to(m * v.right[0] + y0, 6)
          if (y_u1 < u.left[1] and y_u2 > u.right[1]) or (y_u1 > u.left[1] and y_u2 < u.right[1])
            continue
          if (y_v1 < v.left[1] and y_v2 > v.right[1]) or (y_v1 > v.left[1] and y_v2 < v.right[1])
            continue
        else if (u[1] - v[1]) != 0
          if (u.left[0] < u[0] and u.right[0] > u[0]) or (u.left[0] > u[0] and u.right[0] < u[0])
            continue
          if (v.left[0] < v[0] and v.right[0] > v[0]) or (v.left[0] > v[0] and v.right[0] < v[0])
            continue
        else
          continue
        if edges.some((edge) -> Geom.intersect(edge[0], edge[1], u, v))
          continue
        links.push [u, v]

    # anchor start and end nodes
    ###
    anchors = []
    for u in [start.offset, end.offset]
      for v in vertices
        if (u[0] - v[0]) != 0
          [m, y0] = Geom.line(u, v)
          y_v1 = Math.round_to(m * v.left[0] + y0, 6)
          y_v2 = Math.round_to(m * v.right[0] + y0, 6)
          if (y_v1 < v.left[1] and y_v2 > v.right[1]) or (y_v1 > v.left[1] and y_v2 < v.right[1])
            continue
        else if (u[1] - v[1]) != 0
          if (v.left[0] < v[0] and v.right[0] > v[0]) or (v.left[0] > v[0] and v.right[0] < v[0])
            continue
        else
          continue
        if edges.some((edge) -> Geom.intersect(edge[0], edge[1], u, v))
          continue
        anchors.push [u, v]
    ###
    console.log "Link density: ", links.length / vertices.length / vertices.length

    # draw them
    @clear()
    @decorators.push.apply @decorators, vertices.map (v) =>
      color = 'red' unless v.internal
      @paper.circle(v[0], v[1], 5).attr {'stroke': 'none', 'fill': color, 'fill-opacity': 0.5}
    @decorators.push @paper.path(links.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'red', 'stroke-width': 2, 'stroke-opacity': 0.5}
    #decorators.push paper.path(anchors.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'yellow', 'stroke-width': 2, 'stroke-opacity': 0.5}

# Exports
(exports ? @.proc ?= {}).Path = Path
