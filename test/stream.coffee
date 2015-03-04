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
	ob1 = {
		clam: 2
	}

	ob1.fn = ()->
		ob2 = {
			clam: 5
			bound: (param)=>>
				a = await winning(@clam)
				yield a + a
				b = await winning(param)
				yield b + b
				return @
			unbound: ()->>
				a = await winning(@clam)
				yield a + a
				b = await winning(3)
				yield b + b
				return @
		}

		return ob2

	do ->~
		ob2 = ob1.fn()


		bnd = ob2.bound(3)
		v1 = await bnd.next()
		v2 = await bnd.next()
		v3 = await bnd.next()
		eq v1.value, 4
		eq v2.value, 6
		eq v3.value, ob1
		ok v3.done

		ubnd = ob2.unbound()
		v1 = await ubnd.next()
		v2 = await ubnd.next()
		v3 = await ubnd.next()
		eq v1.value, 10
		eq v2.value, 6
		eq v3.value, ob2
		ok v3.done




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











