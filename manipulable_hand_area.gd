extends Node3D


signal clicked(card : Card3D)


@export var cards : Array[Card3D]

const HAND_AREA_WIDTH := 6.0
const CARD_WIDTH := 1.0
const CARD_HEIGHT := 1.5
const CARD_SPACE := 0.1
const SLIDE_CHANGE_DURATION := 0.5
const SLIDE_NOCHANGE_DURATION := 0.1

const CARD_PLAY_MOVE_Y := 1.0

var _hand_positions : Array[Vector3]
var _hand_position_distance : float

var _drag_card : Card3D = null
var _click := false
var _click_relative_point : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in cards:
		c.tween = create_tween()
		c.input_event.connect(on_card3d_input_event)
	align()
	move_card(1)
	pass # Replace with function body.


func align():
	var hand_count := cards.size()
	var step := HAND_AREA_WIDTH / (hand_count + 1)
	var start := step - HAND_AREA_WIDTH/2
	if step < CARD_WIDTH + CARD_SPACE:
		start = step / 10
		step = (HAND_AREA_WIDTH - CARD_WIDTH - start*2) / (hand_count - 1);
		start -= HAND_AREA_WIDTH/2
	_hand_positions.resize(hand_count)
	for i in range(hand_count):
		_hand_positions[i] = Vector3(position.x + start + step * i,position.y,0.01 * (i + 1))
	_hand_position_distance = step

func move_card(sec : float):
	for i in range(cards.size()):
		var tween = create_tween()
		tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(cards[i],"position",_hand_positions[i],sec)
		cards[i].tween.kill()
		cards[i].tween = tween

func move_other_card(card : Card3D,sec : float):
	for i in range(cards.size()):
		if cards[i] == card:
			continue
		var tween = create_tween()
		tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(cards[i],"position",_hand_positions[i],sec)
		cards[i].tween.kill()
		cards[i].tween = tween
	

func get_index_of_position(pos_x : float) -> int:
	var length := pos_x - _hand_positions[0].x
	if length <= 0:
		return 0
	var index := int(length / _hand_position_distance)
	if index >= cards.size():
		return cards.size()
	return index + 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func on_card3d_input_event(card : Card3D,_camera : Camera3D, event : InputEvent, hit_position : Vector3):
	if _click:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			clicked.emit(card)
			_click = false
		elif event is InputEventMouseMotion:
			_drag_card = card
			card.position.z = 0.1
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
				pass
			_drag_card = null
			$MeshInstance3D.material_overlay.albedo_color = Color(0.5,0.5,0.5)
			return
		if event is InputEventMouseMotion:
			if _drag_card.position.y >= position.y + CARD_PLAY_MOVE_Y:
				$MeshInstance3D.material_overlay.albedo_color = Color(0,0,1)
				return
			$MeshInstance3D.material_overlay.albedo_color = Color(0.5,0.5,0.5)
			
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
	if _drag_card:
		_drag_card.set_ray_pickable(true)
	_drag_card = null
	$MeshInstance3D.material_overlay.albedo_color = Color(0.5,0.5,0.5)
	move_card(1)
