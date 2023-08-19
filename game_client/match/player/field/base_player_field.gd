extends I_PlayerField

class_name BasePlayerField


const Card3D_Scene := preload("res://game_client/match/card3d.tscn")
const SkillTitleScene := preload("res://game_client/match/player/field/skill_title.tscn")


var _opponent_layout : bool

@onready var deck_position = $DeckPosition
@onready var avatar_position = $AvatarPosition

@onready var card_holder = $CardHolder
var hand_area : HandArea

@onready var enchant_display = $CanvasLayer/Node2D/EnchantDisplay

var _match_scene : MatchScene = null

var _deck : Array[Card3D]
var _initial_deck_size : int

var _hand : PackedInt32Array = [] # of int
var _played : PackedInt32Array = [] # of int
var _discard : PackedInt32Array = [] # of int
var _stock_count : int
var _life : int = 0
var _damage : int = 0
var _blocked_damage : int

var _playing_card : Card3D = null

var _player_name : String

var _catalog : I_CardCatalog

var _skill_titles : Array[Node2D] = []

var _on_card_clicked : Callable
var _log_display : LogDisplay

var _rival : I_PlayerField


@onready var damage_combat_pos : Vector2 = %Damage.position
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _get_catalog() -> I_CardCatalog:
	return _catalog


func _initialize(match_scene : MatchScene,player_name:String,deck : PackedInt32Array,
		catalog : I_CardCatalog,opponent : bool,
		on_card_clicked : Callable,
		log_display : LogDisplay) -> void:

	_match_scene = match_scene

	for c in card_holder.get_children():
		c.queue_free()
	_initial_deck_size = deck.size()
	_deck.resize(_initial_deck_size)
	var id : int = 0
	var life : int = 0
	for i in deck:
		var cd :=  catalog._get_card_data(i)
		var c := Card3D_Scene.instantiate()
		c.clicked.connect(on_card_clicked)
		var pict = load(cd.image)
		c.initialize(id,cd,cd.name,cd.color,cd.level,cd.power,cd.hit,cd.block,cd.skills,pict,opponent)
		_deck[id] = c
		c.position = deck_position.position
		c.rotation.y = PI
		card_holder.add_child(c)
		life += cd.level
		id += 1
	_stock_count = _deck.size()
	_hand = []
	_played = []
	_discard = []
	_life = life
	_damage = 0

	_playing_card = null
	_player_name = player_name
	$CanvasLayer/Control/LabelName.text = _player_name
	%LabelStockCount.text = str(_stock_count)

	for st in _skill_titles:
		st.visible = false
	%BlockedDamage.visible = false
	%Damage.visible = false
	%CombatStats.visible = false

	enchant_display.initialize(log_display,opponent)
	
	_on_card_clicked = on_card_clicked
	_log_display = log_display
	
	_opponent_layout = opponent
	if opponent:
		rotation_degrees.z = 180
		$CanvasLayer/Control/LabelName.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_KEEP_SIZE)
		
		$CanvasLayer/Node2D.rotation_degrees = 180
		%LabelBlock.rotation_degrees = 180
		%LabelDamage.rotation_degrees = 180
		%LabelStockCount.rotation_degrees = 180
		
	%CombatStats.initialize(opponent)

	_catalog = catalog


func _set_rival(rival : I_PlayerField) -> void:
	_rival = rival

func _set_first_data(data : IGameServer.FirstData.PlayerData) -> void:
	_hand = data.hand
	_life = data.life
	_stock_count -= _hand.size()
	%LabelStockCount.text = str(_stock_count)
	var cards : Array[Card3D] = []
	for h in _hand:
		var card := _deck[h]
		card.location = Card3D.CardLocation.HAND
		card.set_ray_pickable(true)
		cards.append(card)
	hand_area.set_cards(cards)
	hand_area.move_card(1)


func _combat_start(hand : PackedInt32Array,select : int) -> void:
	_playing_card =_deck[hand[select]]
	hand.remove_at(select)
	_hand = hand
	var cards : Array[Card3D] = []
	for h in _hand:
		cards.append(_deck[h])
	hand_area.set_cards(cards)
	
	_playing_card.set_ray_pickable(false)
	_playing_card.location = Card3D.CardLocation.COMBAT
	_life -= _playing_card.level
	
	while _skill_titles.size() < _playing_card.skills.size():
		var title = preload("res://game_client/match/player/field/skill_title.tscn").instantiate()
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

func _get_playing_card() -> Card3D:
	return _playing_card

func _get_enchant_dictionary() -> Dictionary:	# key = id, value = Enchant
	return enchant_display.get_enchant_dictionary()

func _combat_end() -> void:
	_played.append(_playing_card.id_in_deck)
	_playing_card.location = Card3D.CardLocation.PLAYED
	var pos : Vector3 = $PlayedPosition.position
	pos.z += 0.01 * _played.size()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_playing_card,"rotation_degrees:y",180.0,0.25).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():_playing_card.set_render_texture())
	tween.tween_property(_playing_card,"rotation_degrees:y",0.0,0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(_playing_card,"position",pos,0.5)
	tween.parallel().tween_property(_playing_card,"rotation:z",-PI/2,0.5)
	
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	for i in _playing_card.skills.size():
		tween.tween_property(_skill_titles[i],"modulate:a",0.0,1.0)
	tween.tween_property(%CombatStats,"modulate:a",0.0,1.0)
	
	%BlockedDamage.visible = false
	if _damage == 0:
		%Damage.visible = false
	else:
		tween.tween_property(%Damage,"position",Vector2(0.0,damage_combat_pos.y + 20.0),1.0)
		
	await tween.finished
	
	for i in _playing_card.skills.size():
		_skill_titles[i].visible = false
	%CombatStats.visible = false
	_playing_card = null
	return

func _recovery_start(hand : PackedInt32Array,select : int) -> void:
	if select < 0:
		return
	_hand = hand
	var cards : Array[Card3D] = []
	for h in _hand:
		cards.append(_deck[h])
	hand_area.set_cards(cards)

func _recovery_end():
	if _damage <= 0:
		%Damage.visible = false
		%Damage.position = damage_combat_pos
		

func _perform_ability(ability : IGameServer.AbilityLog) -> void:
	var a := _catalog._get_ability_data(ability.ability_id)
	_log_display.append_ability(a.name,_opponent_layout)
	
	var positions := align(ability.card_id.size(),6.0,1.0,0.1)
	var original_pos := PackedVector3Array()
	var original_rotation := PackedVector3Array()
	original_pos.resize(positions.size())
	original_rotation.resize(positions.size())
	var tween := create_tween().set_parallel()
	for i in ability.card_id.size():
		var card := _deck[ability.card_id[i]]
		original_pos[i] = card.position
		original_rotation[i] = card.rotation
		tween.tween_property(card,"position",Vector3(positions[i],0.0,1.0),0.5)
		tween.tween_property(card,"rotation",Vector3.ZERO,0.5)
	tween.chain().tween_interval(0.5)
	await tween.finished
	tween = create_tween().set_parallel()
	for i in ability.card_id.size():
		tween.tween_property(_deck[ability.card_id[i]],"position",original_pos[i],0.5)
		tween.tween_property(_deck[ability.card_id[i]],"rotation",original_rotation[i],0.5)
	await tween.finished
	
	for f in ability.fragment:
		if f.opponent:
			await _rival._perform_effect_fragment(f)
		else:
			await _perform_effect_fragment(f)


func _perform_effect(effect : IGameServer.EffectLog) -> void:
	match effect.type:
		IGameServer.EffectSourceType.SYSTEM_PROCESS:
			_log_display.append_effect_system(_opponent_layout)
			pass
		IGameServer.EffectSourceType.SKILL:
			if effect.fragment.is_empty():
				return
			_log_display.append_effect_skill(_playing_card.skills[effect.id].title,_opponent_layout)
			var origin := _skill_titles[effect.id].position
			var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			var target := Vector2(origin.x,0.0)
			tween.tween_property(_skill_titles[effect.id],"position",target,0.3)
			tween.tween_interval(0.2)
			tween.tween_property(_skill_titles[effect.id],"position",origin,0.3)
			await tween.finished
			pass
		IGameServer.EffectSourceType.ENCHANTMENT:
			await enchant_display.perform(effect.id)
			pass
		IGameServer.EffectSourceType.ABILITY:
			pass
			
	for f in effect.fragment:
		if f.opponent:
			await _rival._perform_effect_fragment(f)
		else:
			await _perform_effect_fragment(f)

func _perform_effect_fragment(fragment : IGameServer.EffectFragment) -> void:
	match fragment.type:
		IGameServer.EffectFragmentType.NO_EFFECT:
			pass
		IGameServer.EffectFragmentType.DAMAGE:
			await perform_fragment_damage(fragment)
			pass
		IGameServer.EffectFragmentType.RECOVERY:
			var recovery_point : int = fragment.data
			_damage -= recovery_point
			_log_display.append_fragment_recovery(recovery_point,_damage,fragment.opponent)
			%LabelDamage.text = str(_damage)
			pass
		IGameServer.EffectFragmentType.INITIATIVE:
			var initiative : bool = fragment.data
			_log_display.append_fragment_initiative(initiative,fragment.opponent)
			await %CombatStats.set_initiative_async(initiative,0.3)
			pass
		IGameServer.EffectFragmentType.COMBAT_STATS:
			var power : int = fragment.data[0]
			var hit : int = fragment.data[1]
			var block : int = fragment.data[2]
			_log_display.append_fragment_combat_stats(power,hit,block,fragment.opponent)
			%CombatStats.set_stats(power,hit,block)
			var card := _get_playing_card()
			var cpower := card.power
			card.update_card_stats(power,hit,block)
			pass
		IGameServer.EffectFragmentType.CARD_STATS:
			var card_id : int = fragment.data[0]
			var power : int = fragment.data[1]
			var hit : int = fragment.data[2]
			var block : int = fragment.data[3]
			var card := _deck[card_id]
			_log_display.append_fragment_card_stats(card.card_name,power,hit,block,fragment.opponent)
			card.update_card_stats(power,hit,block)
			pass
		IGameServer.EffectFragmentType.DRAW_CARD:
			draw_sequence(fragment)
			await draw_coroutine(fragment,0.5)
			pass
		IGameServer.EffectFragmentType.DISCARD_CARD:
			var card_id : int = fragment.data
			var card := _deck[card_id]
			assert (card.location == Card3D.CardLocation.HAND)
			card.set_ray_pickable(false)
			_log_display.append_fragment_discard(card.card_name,fragment.opponent)
			_hand.remove_at(_hand.find(card_id))
			hand_area.set_cards_in_deck(_hand,_deck)
			hand_area.move_card(0.5)
			_discard.append(card_id)
			card.location = Card3D.CardLocation.DISCARD
			var tween := create_tween().set_parallel()
			tween.tween_property(card,"position",avatar_position.position,0.5)
#			tween.tween_method(card.set_albedo_color,Color.WHITE,Color.BLACK,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
			await tween.finished
			pass
		IGameServer.EffectFragmentType.BOUNCE_CARD:
			var card_id : int = fragment.data[0]
			var pos : int = fragment.data[1]
			var card := _deck[card_id]
			assert(card.location == Card3D.CardLocation.HAND)
			card.set_ray_pickable(false)
			_log_display.append_fragment_bounce(card.card_name,pos,fragment.opponent)
			_hand.remove_at(_hand.find(card_id))
			hand_area.set_cards_in_deck(_hand,_deck)
			hand_area.move_card(0.5)
			card.location = Card3D.CardLocation.STOCK
			var tween := create_tween().set_parallel()
			tween.tween_property(card,"position",deck_position.position,0.5)
			tween.tween_property(card,"rotation:y",PI,0.5)
			await tween.finished
			_stock_count += 1
			pass
		
		IGameServer.EffectFragmentType.CREATE_ENCHANTMENT:
			var id : int = fragment.data[0]
			var opponent_source : bool = fragment.data[1]
			var data_id : int = fragment.data[2]
			var param = fragment.data[3]
			var sd : CatalogData.EnchantmentData = (_rival._get_catalog()._get_enchant_data(data_id) if opponent_source
					else _catalog._get_enchant_data(data_id))
			await enchant_display.create_enchantment(id,sd,param,fragment.opponent)
			pass
		IGameServer.EffectFragmentType.UPDATE_ENCHANTMENT:
			var id : int = fragment.data[0]
			var param = fragment.data[1]
			await enchant_display.update_enchantment(id,param,fragment.opponent)
			pass
		IGameServer.EffectFragmentType.DELETE_ENCHANTMENT:
			var id : int = fragment.data[0]
			var expired : bool = fragment.data[1]
			await enchant_display.delete_enchantment(id,expired,fragment.opponent)
			pass
		
		IGameServer.EffectFragmentType.CREATE_CARD:
			var card_id : int = fragment.data[0]
			var opponent_source : bool = fragment.data[1]
			var data_id : int = fragment.data[2]
			var bounce_position : int = fragment.data[3]
			var changes : Dictionary = fragment.data[4]
			
			var catalog := _rival._get_catalog() if opponent_source else _get_catalog() 
			var cd := catalog._get_card_data(data_id)
			var card := Card3D_Scene.instantiate()
			card.clicked.connect(_on_card_clicked)
			var pict = load(cd.image)
			var stats : PackedInt32Array = [cd.power,cd.hit,cd.block]
			var level := cd.level
			for k in changes:
				match k:
					"power":
						stats[0] = changes["power"]
					"hit":
						stats[1] = changes["hit"]
					"block":
						stats[2] = changes["block"]
					"level":
						level = changes["level"]
			card.initialize(card_id,cd,cd.name,cd.color,level,stats[0],stats[1],stats[2],cd.skills,pict,_opponent_layout)
			_deck.resize(card_id + 1)
			_deck[card_id] = card
			card_holder.add_child(card)
			_life += cd.level
			_stock_count += 1

			_log_display.append_fragment_create_card(card,bounce_position,fragment.opponent)

			card.position = $CombatPosition.position
			var tween := create_tween().set_parallel()
			tween.tween_property(card,"position",deck_position.position,0.5)
			tween.tween_property(card,"rotation:y",PI,0.5)
			await tween.finished
			
			pass
		IGameServer.EffectFragmentType.PERFORMANCE:
			pass
	for p in fragment.passive:
		if p.opponent:
			_rival._passive_sequence(p)
			await _rival._passive_coroutine(p,0.2)
		else:
			_passive_sequence(p)
			await _passive_coroutine(p,0.2)


func _passive_sequence(passive : IGameServer.PassiveLog) -> void:
	enchant_display.update_passive_sequence(passive.enchant_id,passive.parameter,passive.opponent)

func _passive_coroutine(passive : IGameServer.PassiveLog,duration : float) -> void:
	await enchant_display.update_passive_coroutine(passive.enchant_id,passive.parameter,duration)


func _perform_simultaneous_initiative(fragment : IGameServer.EffectFragment,duration : float) -> void:
	assert(fragment.type == IGameServer.EffectFragmentType.INITIATIVE)
	var initiative : bool = fragment.data
	
	_log_display.append_effect_system(_opponent_layout)
	_log_display.append_fragment_initiative(initiative,fragment.opponent)
	for p in fragment.passive:
		if p.opponent:
			_rival._passive_sequence(p)
		else:
			_passive_sequence(p)
	
	%CombatStats.set_initiative_async(initiative,duration)
	if not fragment.passive.is_empty():
		var p_duration := duration / fragment.passive.size()
		for p in fragment.passive:
			if p.opponent:
				await _rival._passive_coroutine(p,p_duration)
			else:
				await _passive_coroutine(p,p_duration)

func _perform_simultaneous_supply(effect : IGameServer.EffectLog,duration : float) -> float:
	_log_display.append_effect_system(_opponent_layout)
	var wait_time : float = 0.0
	for f in effect.fragment:
		assert(f.type == IGameServer.EffectFragmentType.DRAW_CARD)
		if draw_sequence(f):
			wait_time += duration
		for p in f.passive:
			if p.opponent:
				_rival._passive_sequence(p)
			else:
				_passive_sequence(p)
	supply_coroutine(effect,duration)
	return wait_time
	
func supply_coroutine(effect : IGameServer.EffectLog,duration : float):
	for f in effect.fragment:
		draw_coroutine(f,duration)
		if not f.passive.is_empty():
			var p_duration := duration / f.passive.size()
			for p in f.passive:
				if p.opponent:
					await _rival._passive_coroutine(p,p_duration)
				else:
					await _passive_coroutine(p,p_duration)
		await get_tree().create_timer(duration).timeout

func draw_sequence(fragment : IGameServer.EffectFragment) -> bool:
	var card_id : int = fragment.data
	if card_id < 0:
		_log_display.append_fragment_no_draw(fragment.opponent)
		return false
	else:
		var card := _deck[card_id]
		_log_display.append_fragment_draw(card.card_name,fragment.opponent)
		card.set_ray_pickable(true)
	return true

func draw_coroutine(fragment : IGameServer.EffectFragment,duration : float):
	var card_id : int = fragment.data
	if card_id < 0:
		return
	var card := _deck[card_id]
	_stock_count -= 1
	%LabelStockCount.text = str(_stock_count)
	card.location = Card3D.CardLocation.HAND
	_hand.append(card_id)
	hand_area.set_cards_in_deck(_hand,_deck)
	hand_area.move_card(duration)
	await get_tree().create_timer(duration).timeout


func perform_fragment_damage(fragment : IGameServer.EffectFragment):
	var unblocked_damage : int = fragment.data[0]
	var blocked_damage : int = fragment.data[1]
	_log_display.append_fragment_damage(unblocked_damage,blocked_damage,fragment.opponent)

	if fragment.opponent:
		await _rival._perform_attack(unblocked_damage,blocked_damage)
	else:
		for i in blocked_damage:
			_damaged(0,1)
			await get_tree().create_timer(0.3).timeout
		for i in unblocked_damage:
			_damaged(1,0)
			await get_tree().create_timer(0.3).timeout
		pass

func _perform_attack(unblocked_damage : int,blocked_damage : int):
	if unblocked_damage + blocked_damage == 0:
		return
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	var origin := _playing_card.position
	for i in unblocked_damage + blocked_damage:
		tween.tween_property(_playing_card,"position:x",0.0,0.15).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(func():
			if i < blocked_damage:
				_rival._damaged(0,1)
			else:
				_rival._damaged(1,0)
		)
		tween.tween_property(_playing_card,"position:x",origin.x,0.15)
	await tween.finished

func _damaged(unblocked_damage : int,blocked_damage : int):
	if unblocked_damage > 0:
		$CombatPosition/AudioStreamPlayer3D.stream = preload("res://sounds/小パンチ.mp3")
	else:
		$CombatPosition/AudioStreamPlayer3D.stream = preload("res://sounds/剣で打ち合う4.mp3")
	_damage += unblocked_damage
	_blocked_damage += blocked_damage
	if _damage > 0:
		%Damage.visible = true
		%LabelDamage.text = str(_damage)
	if _blocked_damage > 0:
		%BlockedDamage.visible = true
		%LabelBlock.text = str(_blocked_damage)
	$CombatPosition/AudioStreamPlayer3D.play()


func _begin_timing(timing : I_PlayerField.EffectTiming) -> void:
	match timing:
		I_PlayerField.EffectTiming.INITIAL:
			pass
		I_PlayerField.EffectTiming.START:
			pass
		I_PlayerField.EffectTiming.BEFORE:
			pass
		I_PlayerField.EffectTiming.MOMENT:
			pass
		I_PlayerField.EffectTiming.AFTER:
			pass
		I_PlayerField.EffectTiming.END:
			pass
	pass

func _finish_timing(timing : I_PlayerField.EffectTiming) -> void:
	enchant_display.force_delete()
	match timing:
		I_PlayerField.EffectTiming.INITIAL:
			pass
		I_PlayerField.EffectTiming.START:
			pass
		I_PlayerField.EffectTiming.BEFORE:
			pass
		I_PlayerField.EffectTiming.MOMENT:
			pass
		I_PlayerField.EffectTiming.AFTER:
			pass
		I_PlayerField.EffectTiming.END:
			pass
	pass

func fix_select_card(card : Card3D):
	await hand_area.fix_select_card(card)



func _on_played_position_clicked():
	var p_list : Array[Card3D] = []
	for c in _played:
		p_list.append(_deck[c])
	var d_list : Array[Card3D] = []
	for c in _discard:
		d_list.append(_deck[c])
	request_card_list_view.emit(p_list,d_list)
	

func align(count : int,area_width : float,item_width : float,space : float) -> PackedFloat32Array:
	var step := area_width / (count + 1)
	var start := step - area_width/2
	if step < item_width + space:
		start = step / 10
		step = (area_width - item_width - start*2) / (count - 1);
		start -= (area_width - item_width)/2
	var output : PackedFloat32Array = []
	output.resize(count)
	for i in count:
		output[i] = start + step * i
	return output


func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		request_enchant_list_view.emit(_get_enchant_dictionary())
		pass


func _set_complete_board(data : IGameServer.CompleteData.PlayerData):
	if not data.additional_deck.is_empty():
		if _deck.size() < _initial_deck_size + data.additional_deck.size():
			for i in range(_deck.size(),_initial_deck_size + data.additional_deck.size()):
				var data_id := data.additional_deck[i - _initial_deck_size][0] as int
				var opponent_source := data.additional_deck[i - _initial_deck_size][1] as bool
				var catalog := _rival._get_catalog() if opponent_source else _catalog
				var cd := catalog._get_card_data(data_id)
				var c := Card3D_Scene.instantiate()
				c.clicked.connect(_on_card_clicked)
				_deck.append(c)
				c.data = cd
				card_holder.add_child(c)
		else:
			for i in range(_initial_deck_size + data.additional_deck.size(),_deck.size()):
				card_holder.remove_child(_deck[i])
				_deck[i].queue_free()
			_deck.resize(_initial_deck_size + data.additional_deck.size())
			
	for i in data.card_change.size():
		var cd := _deck[i].data
		var pict = load(cd.image)
		var stats : PackedInt32Array = [cd.power,cd.hit,cd.block]
		var level := cd.level
		for k in data.card_change[i]:
			match k:
				"power":
					stats[0] = data.card_change[i]["power"]
				"hit":
					stats[1] = data.card_change[i]["hit"]
				"block":
					stats[2] = data.card_change[i]["block"]
				"level":
					level = data.card_change[i]["level"]
		_deck[i].initialize(i,cd,cd.name,cd.color,level,stats[0],stats[1],stats[2],cd.skills,pict,_opponent_layout)
	
	enchant_display.reset()
	for k in data.enchant:
		var value := data.enchant[k] as Array
		var d_id := value[0] as int
		var opponent_source := value[1] as bool
		var param := value[2] as Array
		var catalog := _rival._get_catalog() if opponent_source else _catalog
		enchant_display.set_enchant(k,catalog._get_enchantment_data(d_id),param)
	enchant_display.align()

	for c in _deck:
		c.location = Card3D.CardLocation.STOCK
		c.rotation.z = 0
		c.set_ray_pickable(false)

	_hand = data.hand.duplicate()
	for i in data.hand:
		var card := _deck[i]
		card.location = Card3D.CardLocation.HAND
		card.set_ray_pickable(true)
	hand_area.set_cards_in_deck(data.hand,_deck)
	
	_played = data.played.duplicate()
	for i in data.played.size():
		var card := _deck[data.played[i]]
		card.location = Card3D.CardLocation.PLAYED
		var pos : Vector3 = $PlayedPosition.position
		pos.z += 0.01 * i
		card.position = pos
		card.rotation.z = -PI/2
		
	_discard = data.discard.duplicate()
	for i in data.discard:
		var card := _deck[i]
		card.location = Card3D.CardLocation.DISCARD
		card.position = avatar_position.position
