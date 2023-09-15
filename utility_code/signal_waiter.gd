
class_name SignalWaiter

signal finished

func wait() -> int:
	return -1

func cancel():
	pass


static func wait_all(signals : Array[Signal]) -> void:
	var all := All.new(signals)
	await all.wait()

static func wait_any(signals : Array[Signal]) -> int:
	var any := Any.new(signals)
	return await any.wait()


class All extends SignalWaiter:
	var _done : Array[bool]
	var _signals : Array[Signal]
	
	func _init(signals : Array[Signal]):
		_done.resize(signals.size())
		_signals = signals.duplicate()
		for i in signals.size():
			_done[i] = false
			signals[i].connect(_on_signaled.bind(i))

	func wait() -> int:
		if _done.count(true) == _done.size():
			_release_signals()
			return 0
		await finished
		if _signals.is_empty():
			return -1
		_release_signals()
		return 0

	func cancel():
		_release_signals()
		finished.emit()
		
	func _release_signals():
		for i in _signals.size():
			if _signals[i].is_connected(_on_signaled):
				_signals[i].disconnect(_on_signaled)
		_signals.clear()

	func _on_signaled(index : int):
		_done[index] = true
		if _done.count(true) == _done.size():
			finished.emit()


class Any extends SignalWaiter:
	var _index : int
	var _signals : Array[Signal]
	
	func _init(signals : Array[Signal]):
		_index = -1
		_signals = signals.duplicate()
		for i in signals.size():
			var c := _on_signaled.bind(i)
			signals[i].connect(c)#,CONNECT_ONE_SHOT)

	func wait() -> int:
		if _index >= 0:
			_release_signals()
			return _index
		await finished
		_release_signals()
		return _index

	func cancel():
		_release_signals()
		_index = -1
		finished.emit()

	func _release_signals():
		for i in _signals.size():
			if _signals[i].is_connected(_on_signaled):
				_signals[i].disconnect(_on_signaled)
		_signals.clear()

	func _on_signaled(index : int):
		_index = index
		finished.emit()


