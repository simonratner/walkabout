# Path process: pathfinding
class Path
  constructor: (@paper) ->
    @decorators = @paper.set()

  clear: ->
    @decorators.forEach (i) -> i.remove() or true
    @decorators.clear()

  update: ->
    @clear()
    vertices = []
    edges = []

    console.time("build vertex list")
    entity.Store.each entity.Position, entity.Poly, (ent, pos, poly) =>
      for v in poly
        v_prime = [v[0] + pos[0], v[1] + pos[1]]
        v_prime.left = [v.left[0] + pos[0], v.left[1] + pos[1]]
        v_prime.right = [v.right[0] + pos[0], v.right[1] + pos[1]]
        v_prime.internal = v.internal
        v_prime.neighbours = []
        vertices.push v_prime
        edges.push [v_prime, v_prime.left]
    console.timeEnd("build vertex list")

    # build network
    nodes = []
    console.time("build network")
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
        u.neighbours.push(v)
        v.neighbours.push(u)
        nodes.push(u) if nodes.indexOf(u) == -1
        nodes.push(v) if nodes.indexOf(v) == -1
    console.timeEnd("build network")

    # anchor start and end nodes
    entity.Store.each entity.Position, '$sink', (ent, source, sink) =>
      console.time("build path")
      source = [source[0], source[1]]
      source.neighbours = []
      sink = [sink[0], sink[1]]
      sink.neighbours = []
      for u in [source, sink]
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
          u.neighbours.push(v)
          v.neighbours.push(u)
      if not edges.some((edge) -> Geom.intersect(edge[0], edge[1], source, sink))
        source.neighbours.push(sink)
        sink.neighbours.push(source)
      vertices.push(source, sink)
      nodes.push(source, sink)
      # a*
      alpha = 0.499 # between 0.0 (BFS) and 1.0 (Dijkstra's)
      cost = Geom.dist
      h = Geom.dist
      source.parent = undefined
      source.g = 0
      source.h = h(source, sink)
      source.f = (alpha * source.g + (1 - alpha) * source.h) / Math.max(alpha, 1 - alpha)
      open = [source]
      while open.length > 0
        open.sort (a, b) -> b.f - a.f
        best = open.pop()
        if best is sink
          break
        for n in best.neighbours
          n.g ?= Infinity
          n.h ?= 0
          n.f ?= 0
          c = cost(best, n)
          # Consider this node if the new cost (g) is better than the old cost.
          # The old cost starts at Infinity, so it's always better the first
          # time we see this node.
          if best.g + c < n.g
            n.g = best.g + c
            n.h = h(n, sink)
            n.f = (alpha * n.g + (1 - alpha) * n.h) / Math.max(alpha, 1 - alpha)
            n.parent = best
            open.push(n) if open.indexOf(n) == -1
      console.timeEnd("build path")
      n = sink
      while n.parent?
        @decorators.push @paper.path("M#{n}L#{n.parent}").attr {'stroke': 'red', 'stroke-width': 3, 'stroke-opacity': 0.5}
        n = n.parent

    # draw them
    links = []
    for u in nodes
      for v in u.neighbours
        unless links.some((a) -> (a[0] == u and a[1] == v) or (a[0] == v and a[1] == u))
          links.push [u, v]
    console.log("density:", links.length + "/" + (vertices.length * vertices.length), ",", links.length / vertices.length / vertices.length)
    @decorators.push.apply @decorators, nodes.map (v) =>
      @paper.circle(v[0]+.5, v[1]+.5, 4).attr {'stroke': 'none', 'fill': 'red', 'fill-opacity': 0.5}
    @decorators.push @paper.path(links.map(([u, v]) -> "M#{u}L#{v}").join()).attr {'stroke': 'red', 'stroke-width': 1, 'stroke-opacity': 0.5}

# Exports
(exports ? @.proc ?= {}).Path = Path
