describe 'Entity', ->

  class One
  class Two
  Store = entity.Store

  beforeEach ->
    Store._next_entity_id = 0
    Store.components = {}

  describe 'component name generator', ->
    it 'can convert type to component name', ->
      expect(Store.component_name_from_type(class Mock)).toBe 'Mock'

    it 'can convert string to component name', ->
      expect(Store.component_name_from_type('Mock')).toBe 'Mock'

    it 'can convert number to component name', ->
      expect(Store.component_name_from_type(42)).toBe '42'

    it 'rejects null or undefined component name', ->
      from_null = -> Store.component_name_from_type(null)
      from_undefined = -> Store.component_name_from_type(undefined)
      expect(from_null).toThrow()
      expect(from_undefined).toThrow()

  describe 'factory', ->
    it 'can create entity with no components', ->
      expect(Store.from_components()).toBeDefined()

    it 'can create entity with one typed component', ->
      ent = Store.from_components new One()
      expect(ent).toBeDefined()
      expect(Store.get(ent, One)).toBeDefined()

    it 'can create entity with two typed components', ->
      ent = Store.from_components new One(), new Two()
      expect(ent).toBeDefined()
      expect(Store.get(ent, One)).toBeDefined()
      expect(Store.get(ent, Two)).toBeDefined()

    it 'can create entity with named components', ->
      ent = Store.from_components $one: 1, $two: 2
      expect(ent).toBeDefined()
      expect(Store.get(ent, '$one')).toBe(1)
      expect(Store.get(ent, '$two')).toBe(2)

    it 'can create entity with a mix of typed and named components', ->
      ent = Store.from_components new One(), $one: 1, new Two(), $two: 2
      expect(ent).toBeDefined()
      expect(Store.get(ent, One)).toBeDefined()
      expect(Store.get(ent, Two)).toBeDefined()
      expect(Store.get(ent, '$one')).toBe(1)
      expect(Store.get(ent, '$two')).toBe(2)

  describe 'store', ->
    it 'can add a component to an entity', ->
      ent = Store.from_components()
      Store.add(ent, new One())
      expect(Store.get(ent, One)).toBeDefined()

    it 'can remove a component from an entity', ->
      ent = Store.from_components(new One(), $two: 2)
      Store.remove(ent, One)
      expect(Store.get(ent, One)).toBeUndefined()
      expect(Store.get(ent, '$two')).toBeDefined()

    it 'can remove multiple components from an entity', ->
      ent = Store.from_components(new One(), $two: 2)
      Store.remove(ent, One, '$two')
      expect(Store.get(ent, One)).toBeUndefined()
      expect(Store.get(ent, '$two')).toBeUndefined()

    it 'can delete an entity', ->
      ent = Store.from_components(new One(), $two: 2)
      Store.remove(ent)
      expect(Store.get(ent, One)).toBeUndefined()
      expect(Store.get(ent, '$two')).toBeUndefined()

  describe 'mapper', ->
    c1 = new One()
    c2 = new One()
    c3 = new Two()
    e1 = undefined
    e2 = undefined
    e3 = undefined
    visitor = visit: ->

    beforeEach ->
      e1 = Store.from_components(c1)
      e2 = Store.from_components(c2, $other: 2)
      e3 = Store.from_components(c3, $other: 3)
      spyOn(visitor, 'visit')

    it 'can iterate over entities restricted by component', ->
      Store.each One, visitor.visit
      expect(visitor.visit.calls.length).toBe(2)
      expect(visitor.visit).toHaveBeenCalledWith(e1, c1)
      expect(visitor.visit).toHaveBeenCalledWith(e2, c2)

    it 'can iterate over entities restricted by two components', ->
      Store.each 'Two', '$other', visitor.visit
      expect(visitor.visit.calls.length).toBe(1)
      expect(visitor.visit).toHaveBeenCalledWith(e3, c3, 3)
