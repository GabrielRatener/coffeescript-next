
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
	a = ->~
		x = await winning(5)
		y = await winning(4)
		z = await winning(3)
		return [x, y, z]

	do ->~
		out = await a()
		arrayEq out, [5, 4, 3]

test "boud async", ->
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
		eq await bound(), obj
		ok await unbound() isnt obj

		eq await nested(), obj









