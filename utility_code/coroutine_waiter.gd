
class_name CoroutineWaiter

signal finished

func wait() -> Array:
	return []

func cancel():
	pass


static func wait_all(coroutines : Array[Callable]) -> Array:
	var all := All.new(coroutines)
	return await all.wait()

#static func wait_any(coroutines : Array[Callable]) -> int:
#	var any := Any.new(coroutines)
#	return await any.wait()


class Unit:
	signal finished
	var coroutine : Callable
	var is_finished : bool = false
	var result : Variant = null
	
	func _init(c : Callable):
		coroutine = c
	func start():
		result = await coroutine.call()
		finished.emit()
		is_finished = true

class All extends CoroutineWaiter:
	var _count : int
	var _coroutines : Array[Unit]
	
	func _init(coroutines : Array[Callable]):
		_count = 0
		_coroutines.resize(coroutines.size())
		for i in coroutines.size():
			_coroutines[i] = Unit.new(coroutines[i])
			_coroutines[i].finished.connect(_on_unit_finished.bind(i))
		for c in _coroutines:
			c.start()

	func wait() -> Array:
		if _count == _coroutines.size():
			return _coroutines.map(func(v : Unit):return v.result)
		await finished
		if _count != _coroutines.size():
			return []
		return _coroutines.map(func(v : Unit):return v.result)

	func cancel():
		for i in _coroutines.size():
			if _coroutines[i].finished.is_connected(_on_unit_finished):
				_coroutines[i].finished.disconnect(_on_unit_finished)
		_count = -1
		finished.emit()

	func _on_unit_finished(index : int):
		_coroutines[index].finished.disconnect(_on_unit_finished)
		_count += 1
		if _count == _coroutines.size():
			finished.emit()


class Any extends CoroutineWaiter:
	var _index : int
	var _coroutines : Array[Unit]

	func _init(coroutines : Array[Callable]):
		_index = -1
		_coroutines.resize(coroutines.size())
		for i in coroutines.size():
			_coroutines[i] = Unit.new(coroutines[i])
			_coroutines[i].finished.connect(_on_unit_finished.bind(i))
		for c in _coroutines:
			c.start()

	func wait() -> Array:
		if _index >= 0:
			return [_index,_coroutines[_index].result]
		await finished
		if _index < 0:
			return []
		return [_index,_coroutines[_index].result]

	func cancel():
		for i in _coroutines.size():
			if _coroutines[i].finished.is_connected(_on_unit_finished):
				_coroutines[i].finished.disconnect(_on_unit_finished)
		_index = -1
		finished.emit()


	func _on_unit_finished(index : int):
		_index = index
		for i in _coroutines.size():
			if _coroutines[i].finished.is_connected(_on_unit_finished):
				_coroutines[i].finished.disconnect(_on_unit_finished)
		finished.emit()


