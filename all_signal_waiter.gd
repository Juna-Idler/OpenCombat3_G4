
class_name AllSignalWaiter

signal complete

var _done : Array[bool]

func _init(signals : Array[Signal]):
	_done.resize(signals.size())
	var index := 0
	for s in signals:
		_done[index] = false
		s.connect(on_signaled.bind(index),CONNECT_ONE_SHOT)
		index += 1

func wait():
	if _done.count(true) == _done.size():
		return
	await complete

func on_signaled(index : int):
	_done[index] = true
	if _done.count(true) == _done.size():
		complete.emit()

