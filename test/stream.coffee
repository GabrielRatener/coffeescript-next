global.Promise = require "./importing/promise.js"

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

test "stream as argument", ->
	ok ->>
		await winning()
		yield 5

test "stream definition", ->
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	ok a.next?

test "stream yielding and return", ->
	ob = {}
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	do ->~
		ob.x = await a.next()
		ob.y = await a.next()
		ob.z = await a.next()
		ob.val = await a.next()

	eq ob.x.value, 5
	eq ob.y.value, 4
	eq ob.z.value, 3

	ok not ob.val.value?
	ok not ob.val.hasNext

test "bound streams", ->
	ob = {}
	obj = 
		bound: ->
			return do =>>
				yield this
		unbound: ->
			return do ->>
				yield this
		nested: ->
			return do =>>
				yield do =>>
					yield do =>>
						yield this

	do ->~
		ob.aa = await obj.bound().next()

		ob.bb = await obj.unbound().next()

		gen = obj.nested()
		ob.a = await gen.next()
		ob.b = await ob.a.value.next()
		ob.c = await ob.b.value.next()

	eq ob.aa.value, obj
	ok ob.bb.value isnt obj
	eq ob.c, obj

test "for upon statement", ->
	arr = undefined
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	do ->~
		arr = []
		for n upon a
			arr.push n
	arrayEq arr, [5, 4, 3]

test "for upon expression", ->
	arr = undefined
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	do ->~
		arr = for n upon a
			n
	arrayEq arr, [5, 4, 3]

test "yieldon", ->
	ob = {}
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	b = do ->>
		yieldon a
		return

	do ->~
		ob.x = await b.next()
		ob.y = await b.next()
		ob.z = await b.next()
		ob.val = await b.next()

	eq ob.x.value, 5
	eq ob.y.value, 4
	eq ob.z.value, 3

	ok not ob.val.value?
	ok not ob.val.hasNext











