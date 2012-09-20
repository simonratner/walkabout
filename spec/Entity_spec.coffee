describe 'Entity', ->

  class One
  class Two
  Entity = entity.Entity

  beforeEach ->
    Entity._next_entity_id = 0
    Entity.components = {}

  describe 'component name generator', ->
    it 'can convert type to component name', ->
      expect(Entity.component_name_from_type(class Mock)).toBe 'Mock'

    it 'can convert string to component name', ->
      expect(Entity.component_name_from_type('Mock')).toBe 'Mock'

    it 'can convert number to component name', ->
      expect(Entity.component_name_from_type(42)).toBe '42'

    it 'rejects null or undefined component name', ->
      from_null = -> Entity.component_name_from_type(null)
      from_undefined = -> Entity.component_name_from_type(undefined)
      expect(from_null).toThrow()
      expect(from_undefined).toThrow()

  describe 'factory', ->
    it 'can create entity with no components', ->
      expect(Entity.from_components()).toBeDefined()

    it 'can create entity with one typed component', ->
      ent = Entity.from_components new One()
      expect(ent).toBeDefined()
      expect(Entity.components['One'][ent]).toBeDefined()

    it 'can create entity with two typed components', ->
      ent = Entity.from_components new One(), new Two()
      expect(ent).toBeDefined()
      expect(Entity.components['One'][ent]).toBeDefined()
      expect(Entity.components['Two'][ent]).toBeDefined()

    it 'can create entity with named components', ->
      ent = Entity.from_components $one: 1, $two: 2
      expect(ent).toBeDefined()
      expect(Entity.components['$one'][ent]).toBe(1)
      expect(Entity.components['$two'][ent]).toBe(2)

    it 'can create entity with a mix of typed and named components', ->
      ent = Entity.from_components new One(), $one: 1, new Two(), $two: 2
      expect(ent).toBeDefined()
      expect(Entity.components['One'][ent]).toBeDefined()
      expect(Entity.components['Two'][ent]).toBeDefined()
      expect(Entity.components['$one'][ent]).toBe(1)
      expect(Entity.components['$two'][ent]).toBe(2)

  describe 'manager', ->
    it 'can add a component to an entity', ->
      ent = Entity.from_components()
      Entity.add(ent, new One())
      expect(Entity.components['One'][ent]).toBeDefined()

    it 'can remove a component from an entity', ->
      ent = Entity.from_components(new One(), $two: 2)
      Entity.remove(ent, One)
      expect(Entity.components['One'][ent]).toBeUndefined()
      expect(Entity.components['$two'][ent]).toBeDefined()

    it 'can remove multiple components from an entity', ->
      ent = Entity.from_components(new One(), $two: 2)
      Entity.remove(ent, One, '$two')
      expect(Entity.components['One'][ent]).toBeUndefined()
      expect(Entity.components['$two'][ent]).toBeUndefined()

    it 'can delete an entity', ->
      ent = Entity.from_components(new One(), $two: 2)
      Entity.remove(ent)
      expect(Entity.components['One'][ent]).toBeUndefined()
      expect(Entity.components['$two'][ent]).toBeUndefined()

  describe 'mapper', ->
    c1 = new One()
    c2 = new One()
    c3 = new Two()
    e1 = undefined
    e2 = undefined
    e3 = undefined
    visitor = visit: ->

    beforeEach ->
      e1 = Entity.from_components(c1)
      e2 = Entity.from_components(c2, $other: 2)
      e3 = Entity.from_components(c3, $other: 3)
      spyOn(visitor, 'visit')

    it 'can iterate over entities restricted by component', ->
      Entity.each One, visitor.visit
      expect(visitor.visit.calls.length).toBe(2)
      expect(visitor.visit).toHaveBeenCalledWith(e1, c1)
      expect(visitor.visit).toHaveBeenCalledWith(e2, c2)

    it 'can iterate over entities restricted by two components', ->
      Entity.each 'Two', '$other', visitor.visit
      expect(visitor.visit.calls.length).toBe(1)
      expect(visitor.visit).toHaveBeenCalledWith(e3, c3, 3)
