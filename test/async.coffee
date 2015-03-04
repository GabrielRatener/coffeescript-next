GLOBAL.Promise = require "./promise.js"

winning = (val)->
	return new Promise (win, fail)->
		win(val)
		return

failing = (val)->
	return new Promise (win, fail)->
		fail(val)
		return

hanging = (val)->
	return new Promise (win, fail)->
		return

test "async as argument", ->
	ok ->~
		await winning()

test "async definition", ->
	a = do ->~
		x = await winning(5)
		y = await winning(4)
		z = await winning(3)
		return [x, y, z]

	eq a.constructor, Promise

test "async return type", ->
	out = undefined
	a = ->~
		x = await winning(5)
		y = await winning(4)
		z = await winning(3)
		return [x, y, z]

	do ->~
		out = await a()
	arrayEq out, [5, 4, 3]

test "bound async", ->
	bnd = undefined
	ubnd = undefined
	nst = undefined
	obj = 
		bound: ->
			return do =>~
				return this
		unbound: ->
			return do ->~
				return this
		nested: ->
			return do =>~
				return await do =>~
					return await do =>~
						return this

	do ->~
		bnd = await obj.bound()
		ubnd = await obj.unbound()
		nst = await obj.nested()

	eq bnd, obj
	ok ubnd isnt obj
	eq nst, obj









