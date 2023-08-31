extends Control


signal clicked()
signal held()

@export var timer : Timer = null

var _holding := false

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			if timer != null and not timer.is_stopped():
				timer.stop()
				timer.timeout.disconnect(_on_timer_timeout)
			_holding = false
			var rect := Rect2(Vector2.ZERO,size)
			if rect.has_point((event as InputEventMouseButton).position):
				emit_signal("clicked")
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_holding = true
			if timer != null:
				timer.start()
				timer.timeout.connect(_on_timer_timeout,CONNECT_ONE_SHOT)

func _on_timer_timeout():
	_holding = false
	emit_signal("held")

