describe 'Geom', ->

  beforeEach ->
    @addMatchers
      toBeFinite: ->
        if Array.isArray(@actual)
          @actual.every(isFinite)
        else
          isFinite @actual
      toBeInfinite: ->
        if Array.isArray(@actual)
          !@actual.some(isFinite)
        else
          !isFinite @actual

  it 'can calculate distance between two points', ->
    expect(Geom.dist([0, 0], [3, 4])).toEqual 5
    expect(Geom.dist([3, 4], [0, 0])).toEqual 5
    expect(Geom.dist_squared([0, 0], [3, 4])).toEqual 25
    expect(Geom.dist_squared([3, 4], [0, 0])).toEqual 25
  it 'can calculate distance between a point and itself', ->
    expect(Geom.dist([3, 4], [3, 4])).toEqual 0
    expect(Geom.dist_squared([3, 4], [3, 4])).toEqual 0

  it 'can calculate external (clockwise) angle', ->
    expect(Geom.angle([0, 0], [1, 1], [0, 1])).toEqual 3/4*Math.PI
  it 'can calculate internal (clockwise) angle', ->
    expect(Geom.angle([0, 0], [1, 1], [1, 0])).toEqual -3/4*Math.PI

  it 'can construct a line with zero slope', ->
    expect(Geom.line([0, 1], [1, 1])).toEqual [0, 1]
  it 'can construct a line with zero intercept', ->
    expect(Geom.line([0, 0], [3, 4])).toEqual [4/3, 0]
  it 'can construct a line with non-zero slope and intercept', ->
    expect(Geom.line([0, -1], [-3, 3])).toEqual [-4/3, -1]
  it 'can construct a vertical line', ->
    expect(Geom.line([1, 0], [1, 1])).toBeInfinite()

  it 'can intersect line segments', ->
    expect(Geom.intersect([-1, -1], [2, 2], [1, 0], [0, 1])).toEqual [1/2, 1/2]
  it 'can intersect parallel line segments', ->
    expect(Geom.intersect([-1, -1], [2, 2], [0, 1], [1, 2])).toBeUndefined()
  it 'can intersect non-parallel non-intersecting line segments', ->
    expect(Geom.intersect([-1, -1], [0, 0], [1, 0], [0, 1])).toBeUndefined()
