###
Functional primitives and utilities
###

# define a getter method for property `name`
Function::get = (name, f) ->
  Object.defineProperty @::, name,
    configurable: true
    enumerable: true
    get: f

# define a setter method for property `name`
Function::set = (name, f) ->
  Object.defineProperty @::, name,
    configurable: true
    enumerable: true
    set: f
