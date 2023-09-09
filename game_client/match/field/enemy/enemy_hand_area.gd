extends HandArea

class_name EnemyHandArea


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	_hand_positions[0].y += 0.5
	_hand_position_distance = step
