extends Node3D


const Card3D_Scene := preload("res://game_client/match/card3d.tscn")
const EnchantmentTitleScene := preload("res://game_client/match/player/field/enchantment_title.tscn")
const SkillTitleScene := preload("res://game_client/match/player/field/skill_title.tscn")


var _opponent_layout : bool

@onready var deck_position = $DeckPosition
@onready var avatar_position = $AvatarPosition

@onready var card_holder = $CardHolder
var _hand_area : HandArea = null

@onready var enchant_display = $CanvasLayer/Node2D/EnchantDisplay


var _deck : Array[Card3D]

var _hand : PackedInt32Array = [] # of int
var _played : PackedInt32Array = [] # of int
var _discard : PackedInt32Array = [] # of int
var _stock_count : int
var _life : int = 0
var _damage : int = 0

var _playing_card : Card3D = null

var _player_name : String

var _catalog : I_CardCatalog
var _rival_catalog : I_CardCatalog

var _blocked_damage : int

var _skill_titles : Array[Node2D] = []

var _power_balance : CombatPowerBalance.Interface
var _log_display : LogDisplay


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(hand_area : HandArea,
		player_name:String,deck : PackedInt32Array,
		catalog : I_CardCatalog,opponent : bool,
		cpbi : CombatPowerBalance.Interface,
		log_display : LogDisplay):

	if _hand_area:
		remove_child(_hand_area)
		_hand_area.queue_free()
		_hand_area = null
	_hand_area = hand_area
	_hand_area.name = &"HandArea"
	add_child(hand_area)
	hand_area.position.y = -1.5
	hand_area.position.z = 0.5
	
	for c in card_holder.get_children():
		c.queue_free()
	_deck.resize(deck.size())
	var id : int = 0
	var life : int = 0
	for i in deck:
		var cd :=  catalog._get_card_data(i)
		var c := Card3D_Scene.instantiate()
		var pict = load(cd.image)
		c.initialize(id,cd.name,cd.color,cd.level,cd.power,cd.hit,cd.block,cd.skills,pict,opponent)
		_deck[id] = c
		c.position = deck_position.position
		c.rotation.y = PI
		card_holder.add_child(c)
		life *= cd.level
		id += 1
	_stock_count = _deck.size()
	_hand = []
	_played = []
	_discard = []
	_stock_count = _deck.size()
	_life = life
	_damage = 0

	_playing_card = null
	_player_name = player_name
	$CanvasLayer/Control/LabelName.text = _player_name

	for st in _skill_titles:
		st.visible = false
	%HBoxContainerDamage.visible = false

	enchant_display.initialize(log_display,opponent)
	
	_power_balance = cpbi
	_log_display = log_display
	
	_opponent_layout = opponent
	if opponent:
		rotation_degrees.z = 180
		$CanvasLayer/Control/LabelName.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_KEEP_SIZE)
		
		%HBoxContainerDamage.move_child(%LabelDamage,0)
		var center : Vector2 = $CanvasLayer/Control.size / 2
		var offset = %HBoxContainerDamage.size/2
		var pos = %HBoxContainerDamage.global_position + offset - center
		%HBoxContainerDamage.global_position = center - pos - offset
		%LabelBlock.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		%LabelDamage.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		$CanvasLayer/Node2D.rotation_degrees = 180


	_catalog = catalog

func set_rival_catalog(catalog : I_CardCatalog):
	_rival_catalog = catalog


func set_first_data(data : IGameServer.FirstData.PlayerData):
	_hand = data.hand
	_life = data.life
	_stock_count = _hand.size()
	var cards : Array[Card3D] = []
	for h in _hand:
		_deck[h].location = Card3D.CardLocation.HAND
		cards.append(_deck[h])
	_hand_area.set_cards(cards)
	_hand_area.move_card(1)

	pass

func combat_start(hand : PackedInt32Array,select : int) -> void:
	_playing_card =_deck[hand[select]]
	hand.remove_at(select)
	_hand = hand
	var cards : Array[Card3D] = []
	for h in _hand:
		cards.append(_deck[h])
	_hand_area.set_cards(cards)
	
	_playing_card.location = Card3D.CardLocation.COMBAT
	_life -= _playing_card.level
	
	while _skill_titles.size() < _playing_card.skills.size():
		var title = preload("res://game_client/match/player/field/skill_title.tscn").instantiate()
		_skill_titles.append(title)
		title.position.x = 230
		title.position.y = 100 + 40 * _skill_titles.size()
		$CanvasLayer/Node2D.add_child(title)

	_damage = 0
	_blocked_damage = 0
	%LabelBlock.text = str(0)
	%LabelDamage.text = str(0)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_playing_card,"position",$CombatPosition.position,0.5)
	_hand_area.move_card(0.5)

	tween.set_parallel()
	for i in _playing_card.skills.size():
		_skill_titles[i].initialize(_playing_card.skills[i],_opponent_layout)
		_skill_titles[i].visible = true
		_skill_titles[i].modulate.a = 0.0
		tween.tween_property(_skill_titles[i],"modulate:a",1.0,0.5)
	for i in range(_playing_card.skills.size(),_skill_titles.size()):
		_skill_titles[i].visible = false
		
	
	await tween.finished
	return

func get_playing_card() -> Card3D:
	return _playing_card
func get_enchantment_data(id : int) -> CatalogData.StateData:
	return 


func combat_end() -> void:
	_played.append(_playing_card.id_in_deck)
	_playing_card.location = Card3D.CardLocation.PLAYED
	var pos : Vector3 = $PlayedPosition.position
	pos.z += 0.01 * _played.size()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	tween.tween_property(_playing_card,"position",pos,0.5)
	tween.tween_property(_playing_card,"rotation:z",-PI/2,0.5)
	_playing_card.tween = tween
	for i in _playing_card.skills.size():
		tween.tween_property(_skill_titles[i],"modulate:a",0.0,0.5)
	await tween.finished
	
	for i in _playing_card.skills.size():
		_skill_titles[i].visible = false
	%HBoxContainerDamage.visible = false
	
	_playing_card = null
	return

	
func perform_effect(effect : IGameServer.EffectLog):
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
		IGameServer.EffectSourceType.STATE:
			await enchant_display.perform(effect.id)
			pass
		IGameServer.EffectSourceType.ABILITY:
			pass


func perform_effect_fragment(fragment : IGameServer.EffectFragment):
	match fragment.type:
		IGameServer.EffectFragmentType.NO_EFFECT:
			pass
		IGameServer.EffectFragmentType.DAMAGE:
			var unblocked_damage : int = fragment.data[0]
			var blocked_damage : int = fragment.data[1]
			_log_display.append_fragment_damage(unblocked_damage,blocked_damage,fragment.opponent)
			
			%HBoxContainerDamage.visible = true
			if blocked_damage > 0:
				$CombatPosition/AudioStreamPlayer3D.stream = preload("res://sounds/剣で打ち合う4.mp3")
			for d in blocked_damage:
				_blocked_damage += 1
				var number : String = str(_blocked_damage)
				%LabelBlock.text = number
				$CombatPosition/AudioStreamPlayer3D.play()
				await get_tree().create_timer(0.3).timeout
			if unblocked_damage > 0:
				$CombatPosition/AudioStreamPlayer3D.stream = preload("res://sounds/小パンチ.mp3")
			for d in unblocked_damage:
				_damage += 1
				var number : String = str(_damage)
				%LabelDamage.text = number
				$CombatPosition/AudioStreamPlayer3D.play()
				await get_tree().create_timer(0.3).timeout
			pass
		IGameServer.EffectFragmentType.INITIATIVE:
			var initiative : bool = fragment.data
			pass
		IGameServer.EffectFragmentType.COMBAT_STATS:
			var power : int = fragment.data[0]
			var hit : int = fragment.data[1]
			var block : int = fragment.data[2]
			_log_display.append_fragment_combat_stats(power,hit,block,fragment.opponent)
			var card := get_playing_card()
			var cpower := card.power
			card.update_card_stats(power,hit,block)
			if power > cpower:
				for p in range(cpower,power + 1):
					_power_balance.change_power(p,0.1)
					await get_tree().create_timer(0.1).timeout
			if power < cpower:
				for p in range(cpower,power-1,-1):
					_power_balance.change_power(p,0.1)
					await get_tree().create_timer(0.1).timeout
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
			var card_id : int = fragment.data
			if card_id < 0:
				_log_display.append_fragment_no_draw(fragment.opponent)
				return
			var card := _deck[card_id]
			_log_display.append_fragment_draw(card.card_name,fragment.opponent)
			
			card.location = Card3D.CardLocation.HAND
			_hand.append(card_id)
			_hand_area.set_cards_in_deck(_hand,_deck)
			_hand_area.move_card(0.5)
			await get_tree().create_timer(0.5).timeout
			pass
		IGameServer.EffectFragmentType.DISCARD_CARD:
			var card_id : int = fragment.data
			var card := _deck[card_id]
			_log_display.append_fragment_discard(card.card_name,fragment.opponent)
			if card.location == Card3D.CardLocation.HAND:
				_hand.remove_at(_hand.find(card_id))
				_hand_area.set_cards_in_deck(_hand,_deck)
				_hand_area.move_card(0.5)
			card.location = Card3D.CardLocation.DISCARD
			var tween := create_tween().set_parallel()
			tween.tween_property(card,"position",avatar_position.position,0.5)
			tween.tween_method(card.set_albedo_color,Color.WHITE,Color.BLACK,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
			await tween.finished
			pass
		IGameServer.EffectFragmentType.BOUNCE_CARD:
			var card_id : int = fragment.data[0]
			var pos : int = fragment.data[1]
			var card := _deck[card_id]
			_log_display.append_fragment_bounce(card.card_name,pos,fragment.opponent)

			if card.location == Card3D.CardLocation.HAND:
				_hand.remove_at(_hand.find(card_id))
				_hand_area.set_cards_in_deck(_hand,_deck)
				_hand_area.move_card(0.5)
			card.location = Card3D.CardLocation.STOCK
			var tween := create_tween().set_parallel()
			tween.tween_property(card,"position",deck_position.position,0.5)
			tween.tween_property(card,"rotation:y",PI,0.5)
			await tween.finished
			pass
		
		IGameServer.EffectFragmentType.CREATE_STATE:
			var id : int = fragment.data[0]
			var opponent_source : bool = fragment.data[1]
			var data_id : int = fragment.data[2]
			var param = fragment.data[3]
			var sd := (_rival_catalog._get_state_data(data_id) if opponent_source
					else _catalog._get_state_data(data_id))
			await enchant_display.create_enchantment(id,sd,param)
			pass
		IGameServer.EffectFragmentType.UPDATE_STATE:
			var id : int = fragment.data[0]
			var param = fragment.data[1]
			await enchant_display.update_enchantment(id,param)
			pass
		IGameServer.EffectFragmentType.DELETE_STATE:
			var id : int = fragment.data[0]
			var expired : bool = fragment.data[1]
			await enchant_display.delete_enchantment(id,expired)
			pass
		
		IGameServer.EffectFragmentType.CREATE_CARD:
			var card : int = fragment.data[0]
			var opponent_source : bool = fragment.data[1]
			var data_id : int = fragment.data[2]
			var changes : Dictionary = fragment.data[3]
			pass
		
		IGameServer.EffectFragmentType.PERFORMANCE:
			pass
			
	pass

func perform_passive(passive : IGameServer.PassiveLog) -> void:
	pass


func begin_timing(timing : I_MatchPlayer.EffectTiming) -> void:
	match timing:
		I_MatchPlayer.EffectTiming.INITIAL:
			pass
		I_MatchPlayer.EffectTiming.START:
			pass
		I_MatchPlayer.EffectTiming.BEFORE:
			pass
		I_MatchPlayer.EffectTiming.MOMENT:
			pass
		I_MatchPlayer.EffectTiming.AFTER:
			pass
		I_MatchPlayer.EffectTiming.END:
			pass
	pass

func finish_timing(timing : I_MatchPlayer.EffectTiming) -> void:
	enchant_display.force_delete()
	match timing:
		I_MatchPlayer.EffectTiming.INITIAL:
			pass
		I_MatchPlayer.EffectTiming.START:
			pass
		I_MatchPlayer.EffectTiming.BEFORE:
			pass
		I_MatchPlayer.EffectTiming.MOMENT:
			pass
		I_MatchPlayer.EffectTiming.AFTER:
			pass
		I_MatchPlayer.EffectTiming.END:
			pass
	pass

func fix_select_card(card : Card3D):
	await _hand_area.fix_select_card(card)



