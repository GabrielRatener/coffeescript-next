# Generators
# -----------------
#
# * Generator Definition

test "generator as argument", ->
  ok ->* yield 0

test "generator definition", ->
  x = do ->*
    yield 0
    yield 1
    yield 2
  y = x.next()
  ok y.value is 0 and y.done is false
  y = x.next()
  ok y.value is 1 and y.done is false
  y = x.next()
  ok y.value is 2 and y.done is false
  y = x.next()
  ok y.value is undefined and y.done is true

test "bound generator", ->
  obj =
    bound: ->
      do =>*
        yield this
    unbound: ->
      do ->*
        yield this
    nested: ->
      do =>*
        yield do =>*
          yield do =>*
            yield this

  eq obj, obj.bound().next().value
  ok obj isnt obj.unbound().next().value
  eq obj, obj.nested().next().value.next().value.next().value

test "error if `yield` occurs outside of a function", ->
  throws -> CoffeeScript.compile 'yield 1'

test "error if `yieldall` occurs outside of a function", ->
  throws -> CoffeeScript.compile 'yieldall 1'

test "`yieldall` support", ->
  x = do ->*
    arr = []
    yieldall do ->*
      for i in [1..3]
        a = yield i 
        arr.push a * i
      return
    return arr

  y = x.next()
  ok y.value is 1 and not y.done

  y = x.next 1
  ok y.value is 2 and not y.done

  y = x.next 2
  ok y.value is 3 and not y.done

  y = x.next 2

  arrayEq y.value, [1, 4, 6]
  ok y.done is true

test "yield in if statements", ->
  x = do ->* if 1 is yield 2 then 3 else 4

  y = x.next()
  ok y.value is 2 and y.done is false

  y = x.next 1
  ok y.value is 3 and y.done is true

test "symbolic operators has precedence over the `yield`", ->
  symbolic   = '+ - * / << >> & | || && ** ^ // or and'.split ' '
  compound   = ("#{op}=" for op in symbolic)
  relations  = '< > == != <= >= is isnt'.split ' '

  operators  = [symbolic..., '=', compound..., relations...]

  collect = (gen) -> ref.value until (ref = gen.next()).done

  values = [0, 1, 2, 3]
  for op in operators
    expression = "i #{op} 2"

    yielded = CoffeeScript.eval "(arr) ->*  yield #{expression} for i in arr"
    mapped  = CoffeeScript.eval "(arr) ->       (#{expression} for i in arr)"

    arrayEq mapped(values), collect yielded values

test "for loop expressions", ->
  x = do ->*
    y = for i in [1..3]
      yield i * 2

  z = x.next()
  ok z.value is 2 and z.done is false
  z = x.next 10
  ok z.value is 4 and z.done is false
  z = x.next 20
  ok z.value is 6 and z.done is false
  z = x.next 30
  arrayEq z.value, [10, 20, 30]
  ok z.done is true

test "switch expressions", ->
  x = do ->*
    y = switch yield 1
      when 2 then yield 1337

  z = x.next()
  ok z.value is 1 and z.done is false
  z = x.next 2
  ok z.value is 1337 and z.done is false
  z = x.next 3
  ok z.value is 3 and z.done is true

test "for from statement", ->
  x = do ->*
    yield 1
    yield 2
    yield 3
    yield 4

  arr = []
  for i from x
    a = i * i
    b = a + 1
    arr.push b

  arrayEq arr, [2, 5, 10, 17]
  return

test "for from expression", ->
  x = do ->*
    yield 1
    yield 2
    yield 3
    yield 4

  arr = for i from x
    i
  arrayEq arr, [1, 2, 3, 4]

