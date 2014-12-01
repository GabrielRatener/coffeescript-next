
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
	a = do ->>
		x = await winning(5)
		yield x
		y = await winning(4)
		yield y
		z = await winning(3)
		yield z

	do ->~
		x = await a.next()
		y = await a.next()
		z = await a.next()

		eq x.value, 5
		eq y.value, 4
		eq z.value, 3

		val = await a.next()
		ok not val.value?
		ok not val.hasNext

test "bound streams", ->
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
		a = await bound().next()
		eq a.value, obj

		b = await unbound().next()
		ok b.value isnt obj

		gen = nested()
		a = await gen.next()
		b = await a.value.next()
		c = await b.value.next()

		eq c, obj

test "for upon statement", ->
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
		arraEq arr, [5, 4, 3]

test "for upon expression", ->
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
		arraEq arr, [5, 4, 3]

test "yieldon", ->
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
		x = await b.next()
		y = await b.next()
		z = await b.next()

		eq x.value, 5
		eq y.value, 4
		eq z.value, 3

		val = await b.next()
		ok not val.value?
		ok not val.hasNext











