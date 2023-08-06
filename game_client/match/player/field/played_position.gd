extends Node3D


signal clicked

var _click : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#
#func append_card(card : Card3D,duration : float):
#	card.set_ray_pickable(false)
#	cards.append(card)
#	var tween := create_tween()
#	card.tween.kill()
#	card.tween = tween
#	tween.tween_property(card,"position",Vector3(0,0,0.01 * cards.size()),duration)
#	tween.tween_property(card,"rotation_degrees",-90,duration)
#
#	var box := $Area3D/CollisionShape3D.shape as BoxShape3D
#	box.size.z = (0.01 * (cards.size() + 1)) * 2
#
#func remove_card(card : Card3D):
#	card.set_ray_pickable(true)
#	cards.erase(card)
#	for i in cards.size():
#		cards[i].position = Vector3(0,0,0.01 * (i + 1))
#	var box := $Area3D/CollisionShape3D.shape as BoxShape3D
#	box.size.z = (0.01 * (cards.size() + 1)) * 2
#
#
#func gather(duration : float):
#	for i in cards.size():
#		var tween := create_tween()
#		var card := cards[i]
#		card.set_ray_pickable(false)
#		card.tween.kill()
#		card.tween = tween
#		tween.tween_property(card,"position",Vector3(0,0,0.01 * (i + 1)),duration)
#		tween.tween_property(card,"rotation_degrees",-90,duration)



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
