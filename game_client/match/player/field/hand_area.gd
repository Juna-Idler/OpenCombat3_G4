extends Node3D

class_name HandArea


signal clicked(card : Card3D)


var cards : Array[Card3D]

const HAND_AREA_WIDTH := 6.0
const CARD_WIDTH := 1.0
const CARD_HEIGHT := 1.5
const CARD_SPACE := 0.1


var _hand_positions : Array[Vector3]
var _hand_position_distance : float

var _click := false


# Called when the node enters the scene tree for the first time.
func _ready():

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
	pass

func align():
	var hand_count := cards.size()
	var step := HAND_AREA_WIDTH / (hand_count + 1)
	var start := step - HAND_AREA_WIDTH/2
	if step < CARD_WIDTH + CARD_SPACE:
		start = step / 10
		step = (HAND_AREA_WIDTH - CARD_WIDTH - start*2) / (hand_count - 1);
		start -= (HAND_AREA_WIDTH - CARD_WIDTH)/2
	_hand_positions.resize(hand_count)
	for i in range(hand_count):
		_hand_positions[i] = Vector3(position.x + start + step * i,position.y,position.z + 0.01 * (i + 1))
	_hand_position_distance = step

func move_card(sec : float):
	for i in range(cards.size()):
		var tween = create_tween()
		tween.set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(cards[i],"position",_hand_positions[i],sec)
		tween.tween_property(cards[i],"rotation_degrees:y",0,sec)
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


func on_card3d_input_event(card : Card3D,_camera : Camera3D, event : InputEvent, _hit_position : Vector3):
	if _click:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			clicked.emit(card)
			_click = false
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_click = true
	pass


func fix_select_card(card : Card3D):
	var index := cards.find(card)
	if index < 0:
		return
	var pos := _hand_positions[index]
	pos.y += 0.5
	pos.z = position.z + 0.5
	var tween := create_tween()
	tween.tween_property(card,"position",pos,0.3)
	await tween.finished

