extends "res://game_client/match/player/field/hand_area.gd"



signal selected(index : int,hand : Array[Card3D])

signal entered_play_zone(card : Card3D)
signal exited_play_zone(card : Card3D)


const SLIDE_CHANGE_DURATION := 0.5
const SLIDE_NOCHANGE_DURATION := 0.1

const CARD_PLAY_MOVE_Y := 1.0


var _drag_card : Card3D = null
var _click_relative_point : Vector3
var _in_play_zone : bool = false
var _selected_card : Card3D = null

var _playable : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_playable(playable : bool):
	if _playable and not playable:
		if _drag_card:
			$AllArea.input_ray_pickable = false
			_drag_card.set_ray_pickable(true)
			_drag_card = null
		_in_play_zone = false
		_click = false
	_playable = playable

func is_playable() -> bool:
	return _playable


func get_index_of_position(pos_x : float) -> int:
	var length := pos_x - _hand_positions[0].x
	if length <= 0:
		return 0
	var index := int(length / _hand_position_distance)
	if index >= cards.size():
		return cards.size()
	return index + 1


func on_card3d_input_event(card : Card3D,_camera : Camera3D, event : InputEvent, hit_position : Vector3):
	if _click:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			clicked.emit(card)
			_click = false
		elif event is InputEventMouseMotion:
			if _playable:
				_drag_card = card
				card.position.z = position.z + 0.1
				card.set_ray_pickable(false)
				card.tween.kill()
				$AllArea.input_ray_pickable = true
			_click = false
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_click_relative_point = hit_position - card.global_position
			_click_relative_point.z = 0
			_click = true
	pass

func _on_all_area_input_event(_camera, event, hit_position, _normal, _shape_idx):
	if _drag_card:
		_drag_card.position = Vector3(hit_position.x,hit_position.y,_drag_card.position.z) - _click_relative_point
		
	if event is InputEventMouse:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			_drag_card.set_ray_pickable(true)
			$AllArea.input_ray_pickable = false
			if _drag_card.position.y >= position.y + CARD_PLAY_MOVE_Y:
				_selected_card = _drag_card
				selected.emit(cards.find(_drag_card),cards)
			return
		if event is InputEventMouseMotion:
			if _drag_card.position.y >= position.y + CARD_PLAY_MOVE_Y:
				if not _in_play_zone:
					_in_play_zone = true
					entered_play_zone.emit(_drag_card)
				return
			else:
				if _in_play_zone:
					_in_play_zone = false
					exited_play_zone.emit(_drag_card)
			
			var index := cards.find(_drag_card)
			var area_index := get_index_of_position(hit_position.x)
			if index != area_index and index + 1 != area_index:
				var swap_index := index + (1 if area_index > index else -1)
				cards[index] = cards[swap_index]
				cards[swap_index] = _drag_card
				move_other_card(_drag_card,0.3)
			pass


func _on_all_area_mouse_exited():
	$AllArea.input_ray_pickable = false
	if _selected_card:
		move_other_card(_selected_card,0.5)
		_selected_card = null
	else:
		move_card(0.5)
	if _drag_card:
		_drag_card.set_ray_pickable(true)
		_drag_card = null
	_in_play_zone = false

