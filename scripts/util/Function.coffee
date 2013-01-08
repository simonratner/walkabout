###
Functional primitives and utilities
###

# Define getter methods for properties of attr
Function::getattr = (attr) ->
  for name, f of attr
    Object.defineProperty @::, name,
      configurable: true
      enumerable: true
      get: f

# Define setter methods for properties of attr
Function::setattr = (attr) ->
  for name, f of attr
    Object.defineProperty @::, name,
      configurable: true
      enumerable: true
      set: f
