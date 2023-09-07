extends BasePlayerField


var initial_life : int

# Called when the node enters the scene tree for the first time.
func _ready():
	hand_area = $HandArea
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _combat_start(hand : PackedInt32Array,select : int) -> void:
	_playing_card =_deck[hand[select]]
	_hand = hand.duplicate()
	_hand.remove_at(select)
	hand_area.set_cards_in_deck(_hand,_deck)
	
	_playing_card.set_ray_pickable(false)
	_playing_card.location = Card3D.CardLocation.COMBAT
#	_life -= _playing_card.level
	
	while _skill_titles.size() < _playing_card.skills.size():
		var title = preload("res://game_client/match/field/parts/skill_title.tscn").instantiate()
		_skill_titles.append(title)
		title.position.x = 230
		title.position.y = 100 + 40 * _skill_titles.size()
		title.visible = false
		$CanvasLayer/Node2D.add_child(title)


	%CombatStats.set_color(CatalogData.RGB[_playing_card.color])
	%CombatStats.set_stats(_playing_card.power,_playing_card.hit,_playing_card.block)
	%CombatStats.visible = true
	%CombatStats.modulate.a = 0.0

	_damage = 0
	_blocked_damage = 0
	%LabelBlock.text = str(0)
	%LabelDamage.text = str(0)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_playing_card,"position",$CombatPosition.position,0.5)
	hand_area.move_card(0.5)
	tween.tween_property(_playing_card,"rotation_degrees:y",180.0,0.25).set_ease(Tween.EASE_IN)
#	tween.tween_callback(_playing_card.set_picture_texture)
	await tween.finished
	
	_playing_card.set_picture_texture()
	
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_playing_card,"rotation_degrees:y",360.0,0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(%CombatStats,"modulate:a",1.0,0.25)

	for i in _playing_card.skills.size():
		_skill_titles[i].initialize(_playing_card.skills[i],_opponent_layout)
		_skill_titles[i].visible = true
		_skill_titles[i].modulate.a = 0.0
		tween.tween_property(_skill_titles[i],"modulate:a",1.0,0.25)
	for i in range(_playing_card.skills.size(),_skill_titles.size()):
		_skill_titles[i].visible = false

	await tween.finished
	return
