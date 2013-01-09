# Store
Store =
  components: {}
  templates: {}

  component_name_from_type: (type) ->
    if type.constructor.name == 'Function'
      type.name
    else
      type.toString()

  add: (ent, components...) ->
    ###
    Add specified entity components. Components can be named by providing a
    dictionary of name:component pairs, or they can be non-primitive values,
    in which case the component name is derived from the value's type.
    ###
    for component in components
      component_name = component.constructor.name
      if component_name == 'Object'
        # Decompose dictionary arguments into named components
        for component_name, c of component
          @components[component_name] ?= {}
          @components[component_name][ent] = c
          @emit("added/#{component_name}", ent, c)
      else
        @components[component_name] ?= {}
        @components[component_name][ent] = component
        @emit("added/#{component_name}", ent, component)

  get: (ent, component_type) ->
    @components[@component_name_from_type(component_type)]?[ent]

  remove: (ent, component_types...) ->
    ### Remove specified entity components, or remove the entity if no components specified. ###
    if component_types.length > 0
      for c in component_types.map(@component_name_from_type)
        delete @components[c][ent] if c of @components
        @emit("removed/#{c}", ent)
    else
      for c, components of @components
        delete components[ent]
        @emit("removed/#{c}", ent)
    return

  each: (component_types..., f) ->
    ### Iterate over entities containing one or more specified components. ###
    [first, rest...] = component_types.map @component_name_from_type
    for ent, component of @components[first]
      if rest.every((c) => ent of @components[c])
        f(ent, component, (@components[c][ent] for c in rest)...)
    return

  from_components: (components...) ->
    ### Create new entity from specified components. ###
    @add String(@_next_entity_id), components...
    String(@_next_entity_id++)

  from_template: (template_name, args...) ->
    @templates[template_name].apply(@, args)

  _next_entity_id: 0

smokesignals.convert(Store)

# Exports
(exports ? @.entity ?= {}).Store = Store
