extends "res://game_client/match/player/field/hand_area/hand_area.gd"


signal selected(index : int,hand : Array[Card3D])

signal entered_play_zone(card : Card3D)
signal exited_play_zone(card : Card3D)


const SLIDE_CHANGE_DURATION := 0.5
const SLIDE_NOCHANGE_DURATION := 0.1

const CARD_PLAY_MOVE_Y := 1.0

@onready var card_aura : CardAura = $CardAura

var _click : bool = false
var _drag_card : Card3D = null
var _click_relative_point : Vector3
var _in_play_zone : bool = false
var _selected_card : Card3D = null

var _playable : bool = true

var _aura_tween : Tween



# Called when the node enters the scene tree for the first time.
func _ready():
	_aura_tween = create_tween()
	_aura_tween.kill()
	remove_child(card_aura)
	pass # Replace with function body.

func set_cards(new_cards : Array[Card3D]):
	for c in cards:
		if not new_cards.has(c):
			c.input_event.disconnect(on_card3d_input_event)
	for c in new_cards:
		if not cards.has(c):
			c.input_event.connect(on_card3d_input_event)
	cards = new_cards
	align()

func set_cards_in_deck(new_hand : PackedInt32Array,deck : Array[Card3D]):
	var new_cards : Array[Card3D] = []
	for h in new_hand:
		var card := deck[h]
		new_cards.append(card)
		if not cards.has(card):
			card.input_event.connect(on_card3d_input_event)
	for c in cards:
		if not new_cards.has(c):
			c.input_event.disconnect(on_card3d_input_event)
	cards = new_cards
	align()


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
		if event is InputEventMouseMotion:
			if _playable:
				_drag_card = card
				card.position.z = position.z + 0.1
				card.set_ray_pickable(false)
				card.tween.kill()
				$AllArea.input_ray_pickable = true
				put_on_aura(card)
			_click = false
			card._click = false
		else:
			if (event is InputEventMouseButton
					and event.button_index == MOUSE_BUTTON_LEFT
					and not event.pressed):
				_click = false
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_click_relative_point = hit_position - card.global_position
			_click_relative_point.z = 0
			_click = true


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
				take_off_aura(_drag_card)
				selected.emit(cards.find(_selected_card),cards)
				_drag_card = null
			return
		if event is InputEventMouseMotion:
			if _drag_card.position.y >= position.y + CARD_PLAY_MOVE_Y:
				if not _in_play_zone:
					_in_play_zone = true
					set_playing_aura_color()
					entered_play_zone.emit(_drag_card)
				return
			else:
				if _in_play_zone:
					_in_play_zone = false
					set_selecting_aura_color()
					exited_play_zone.emit(_drag_card)
			
			var index := cards.find(_drag_card)
			var area_index := get_index_of_position(_drag_card.position.x)
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
		take_off_aura(_drag_card)
		_drag_card.set_ray_pickable(true)
		_drag_card = null
	_in_play_zone = false

func put_on_aura(card : Card3D):
	_aura_tween.kill()
	if card_aura.get_parent():
		card_aura.get_parent().remove_child(card_aura)
	card.add_child(card_aura)
	_aura_tween = create_tween()
	_aura_tween.tween_method(card_aura.set_aura_intensity,0.0,1.0,0.3)
	set_selecting_aura_color()

func take_off_aura(card : Card3D):
	_aura_tween.kill()
	_aura_tween = create_tween()
	_aura_tween.tween_method(card_aura.set_aura_intensity,1.0,0.0,0.3)
	_aura_tween.tween_callback(card.remove_child.bind(card_aura))

func set_playing_aura_color():
	card_aura.set_aura_color(Color.WHITE) #CatalogData.RGB[_drag_card.color].lightened(0.5))

func set_selecting_aura_color():
	card_aura.set_aura_color(CatalogData.RGB[_drag_card.color])


