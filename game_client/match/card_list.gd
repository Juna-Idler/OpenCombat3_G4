extends Node3D


const AREA_WIDTH := 6.0
const CARD_WIDTH := 1.0
const CARD_HEIGHT := 1.5
const CARD_SPACE := 0.1


signal clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

class OriginalPosition:
	var card : Card3D
	var position : Vector3
	var rotation : Vector3
	var visible : bool
	
	func _init(c,p,r,v):
		card = c
		position = p
		rotation = r
		visible = v

var original_position : Array[OriginalPosition]


func put_cards(p_cards : Array[Card3D],d_cards : Array[Card3D],duration : float):
	original_position = []
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	var count := p_cards.size()
	var step := AREA_WIDTH / (count + 1)
	var start := step - AREA_WIDTH/2
	if step < CARD_WIDTH + CARD_SPACE:
		start = step / 10
		step = (AREA_WIDTH - CARD_WIDTH - start*2) / (count - 1);
		start -= (AREA_WIDTH - CARD_WIDTH)/2
	
	for i in p_cards.size():
		var c := p_cards[i]
		original_position.append(OriginalPosition.new(c,c.position,c.rotation,c.visible))
		c.visible = true
		c.set_ray_pickable(true)
		var pos := Vector3(position.x + start + step * i,position.y + 1,position.z + 0.01 * (i + 1))
		tween.tween_property(c,"global_position",pos,duration)
		tween.tween_property(c,"rotation",Vector3.ZERO,duration)
		
	count = d_cards.size()
	step = AREA_WIDTH / (count + 1)
	start = step - AREA_WIDTH/2
	if step < CARD_WIDTH + CARD_SPACE:
		start = step / 10
		step = (AREA_WIDTH - CARD_WIDTH - start*2) / (count - 1);
		start -= (AREA_WIDTH - CARD_WIDTH)/2
	for i in d_cards.size():
		var c := d_cards[i]
		original_position.append(OriginalPosition.new(c,c.position,c.rotation,c.visible))
		c.visible = true
		c.set_ray_pickable(true)
		var pos = Vector3(position.x + start + step * i,position.y - 1,position.z + 0.01 * (i + 1))
		tween.tween_property(c,"global_position",pos,duration)
		tween.tween_property(c,"rotation",Vector3.ZERO,duration)
	
	await tween.finished
	$Sprite3D.visible = true
	

func restore(duration : float):
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	for op in original_position:
		op.card.set_ray_pickable(false)
		tween.tween_property(op.card,"position",op.position,duration)
		tween.tween_property(op.card,"rotation",op.rotation,duration)
	await tween.finished
	for op in original_position:
		op.card.visible = op.visible
	original_position = []

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		$Sprite3D.visible = false
		clicked.emit()
		restore(0.3)
