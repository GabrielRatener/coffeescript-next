            {
         }   }   {
        {   {  }  }
         }   }{  {
        {  }{  }  }                    _____       __  __
       { }{ }{  { }                   / ____|     / _|/ _|
     .- { { }  { }} -.               | |     ___ | |_| |_ ___  ___
    (  { } { } { } }  )              | |    / _ \|  _|  _/ _ \/ _ \
    |`-..________ ..-'|              | |___| (_) | | | ||  __/  __/
    |                 |               \_____\___/|_| |_| \___|\___|
    |                 ;--.
    |                (__  \            _____           _       _
    |                 | )  )          / ____|         (_)     | |
    |                 |/  /          | (___   ___ _ __ _ _ __ | |_
    |                 (  /            \___ \ / __| '__| | '_ \| __|
    |                 |/              ____) | (__| |  | | |_) | |_
    |                 |              |_____/ \___|_|  |_| .__/ \__|
     `-.._________..-'                                  | |
                                                        |_|

CoffeeScript-next is a non-backwards compatible fork of CoffeeScript that utilizes ES6 features to add asynchrony and coroutines to the language.

## New Syntax

### Async Function

Use `->~` to make the function async:

```Coffeescript
my_async_fn = () ->~
            value = await a_promise  # a_promise must be A+ spec compliant
            return value
```

Invoking Async functions always returns a promise.

### Generator Functions

use `->*` to turn the function into a generator function:

```Coffeescript
my_generator_fn = () ->*
            yield 5
            return_val = yield 4    # same as ES6
            return value
```

Generator functions compile down to ES6 generators, with `yield` having the same meaning as in ES6.

### Async Generator Functions

use `->>` to make the function into an async generator function:

```Coffeescript
my_async_generator_fn = () ->>
            yield 5
            yield 4    # same as ES6
            await some_promise
            await some_promise_returning_function()
            return
```

Calling such a function returns an async iterator, which can be used by a for-upon loop (see below)

### For-from Loops

```Coffeescript
my_generator_fn = () ->*
            yield 5
            yield 4
            return
            
for num from my_generator_fn()
            console.log num

###
prints:
 5
 4
###
```

For-from loops can be used to iterate over any object that properly implements the iterable spec.

### For-upon loops

```Coffeescript
my_async_generator_fn = () ->>
            await some_promise
            yield 1
            await some_other_promise
            yield 6
            return

# can only run for-upon loops in async or async-generator functions
do ->~
            for num upon my_async_generator_fn()
                        console.log num

###
prints:
 1
 6
###
```

A for upon loop iterates through the values yielded by an async generator.

### The `yieldall` Keyword

`yieldall` is syntactically equivalent to `yield*` in ES6 except that it cannot be evaluated as an expression (working on that):

```Coffeescript
my_other_generator_fn = () ->*
            yield 1
            yield 3

my_generator_fn = () ->*
            yield 5
            yield 4
            yieldall my_other_generator_fn()
            return
            
for num from my_generator_fn()
            console.log num

###
prints:
 5
 4
 1
 3
###
```

### The `yieldon` Keyword

A `yieldall` analog for delegating to async generators

```Coffeescript
my_other_async_generator_fn = () ->>
            await some_promise
            yield 4
            await some_other_promise
            yield 5
            return
            
my_async_generator_fn = () ->>
            await some_promise
            yield 1
            await some_other_promise
            yield 6
            yieldon my_other_async_generator()
            return

do ->~         
            for num upon my_async_generator_fn()
                        console.log num

###
prints:
 1
 6
 4
 5
###
```
