extends BasePlayerField

class_name EnemyField


var initial_life : int

# Called when the node enters the scene tree for the first time.
func _ready():
	hand_area = $HandArea
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_avatar_texture(texture : Texture2D):
	$AvatarPosition.texture = texture

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

func _recovery_end(life : int):
	_life = life
	%LabelLife.text = str(_life)
	%Damage.visible = false
	%Damage.position = damage_combat_pos

func _perform_effect_discard_card_fragment(card_id : int,opponent : bool):
	var card := _deck[card_id]
	assert (card.location == Card3D.CardLocation.HAND or card.location == Card3D.CardLocation.STOCK)
#	_life -= card.level
#	%LabelLife.text = str(_life)
	if card.location == Card3D.CardLocation.HAND:
		card.set_ray_pickable(false)
		_hand.remove_at(_hand.find(card_id))
		hand_area.set_cards_in_deck(_hand,_deck)
		hand_area.move_card(0.5)
	elif card.location == Card3D.CardLocation.STOCK:
		_stock_count -= 1
	_log_display.append_fragment_discard(card.card_name,opponent)
	_discard.append(card_id)
	card.location = Card3D.CardLocation.DISCARD
	var tween := create_tween().set_parallel()
	tween.tween_property(card,"position",avatar_position.position,0.5)
#			tween.tween_method(card.set_albedo_color,Color.WHITE,Color.BLACK,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await tween.finished
