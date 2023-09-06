extends Node3D


signal clicked

var _click : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area_3d_input_event(_camera : Camera3D, event : InputEvent, _hit_position : Vector3, _normal : Vector3, _shape_idx : int):
	if _click:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			clicked.emit()
			_click = false
		elif event is InputEventMouseMotion:
			_click = false
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_click = true
	pass
