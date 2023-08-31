extends Control


signal clicked()

var _pressed := false

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _pressed:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			_pressed = false
			var rect := Rect2(Vector2.ZERO,size)
			if rect.has_point((event as InputEventMouseButton).position):
				emit_signal("clicked")
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_pressed = true
