extends Node3D


const Card3D_Scene := preload("res://game_client/match/card3d.tscn")

class Enchantment:
	var data : CatalogData.StateData
	var parameter : Array
	var title : String

	func _init(d,p):
		data = d
		parameter = p
		var p_str := Global.card_catalog.param_to_string(data.param_type,parameter)
		title = data.name + ("" if p_str.is_empty() else "(" + p_str + ")" )
	
	func change_parameter(p):
		parameter = p
		var p_str := Global.card_catalog.param_to_string(data.param_type,parameter)
		title = data.name + ("" if p_str.is_empty() else "(" + p_str + ")" )


var _opponent_layout : bool

@onready var deck_position = $DeckPosition
@onready var avatar_position = $AvatarPosition

@onready var card_holder = $CardHolder
var _hand_area : HandArea = null


var _deck : Array[Card3D]

var _hand : PackedInt32Array = [] # of int
var _played : PackedInt32Array = [] # of int
var _discard : PackedInt32Array = [] # of int
var _stock_count : int
var _life : int = 0
var _damage : int = 0

var _states : Dictionary = {} # key int, value Enchantment

var _playing_card : Card3D = null

var _player_name : String

var _catalog : I_CardCatalog
var _rival_catalog : I_CardCatalog

var _blocked_damage : int

var _skill_titles : Array[Node2D] = []



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(hand_area : HandArea,
		player_name:String,deck : PackedInt32Array,catalog : I_CardCatalog,opponent : bool):

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

	_states = {}
	_playing_card = null
	_player_name = player_name
	$CanvasLayer/Control/LabelName.text = _player_name
	
	_opponent_layout = opponent
	if opponent:
		rotation_degrees.z = 180
		$CanvasLayer/Control/CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT,Control.PRESET_MODE_MINSIZE)
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
			pass
		IGameServer.EffectSourceType.SKILL:
			if effect.fragment.is_empty():
				return
			var origin := _skill_titles[effect.id].position
			var tween := create_tween()
			var target := Vector2(origin.x,0.0)
			tween.tween_property(_skill_titles[effect.id],"position",target,0.3)
			await tween.finished
			tween = create_tween()
			tween.tween_interval(0.5)
			tween.tween_property(_skill_titles[effect.id],"position",origin,0.5)
			pass
		IGameServer.EffectSourceType.STATE:
			_states[effect.id]
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
			var card := get_playing_card()
			card.update_card_stats(power,hit,block)
			pass
		IGameServer.EffectFragmentType.CARD_STATS:
			var card_id : int = fragment.data[0]
			var power : int = fragment.data[1]
			var hit : int = fragment.data[2]
			var block : int = fragment.data[3]
			var card := _deck[card_id]
			card.update_card_stats(power,hit,block)
			pass
		IGameServer.EffectFragmentType.DRAW_CARD:
			var card_id : int = fragment.data
			if card_id < 0:
				return
			var card := _deck[card_id]
			card.location = Card3D.CardLocation.HAND
			_hand.append(card_id)
			_hand_area.set_cards_in_deck(_hand,_deck)
			_hand_area.move_card(0.5)
			await get_tree().create_timer(0.5).timeout
			pass
		IGameServer.EffectFragmentType.DISCARD:
			var card_id : int = fragment.data
			var card := _deck[card_id]
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
			var card : int = fragment.data[0]
			var pos : int = fragment.data[1]
			pass
		
		IGameServer.EffectFragmentType.CREATE_STATE:
			var state_id : int = fragment.data[0]
			var opponent_source : bool = fragment.data[1]
			var data_id : int = fragment.data[2]
			var param = fragment.data[3]
			var sd := _rival_catalog._get_state_data(data_id)
			_states[state_id] = Enchantment.new(sd,param)
			update_label_enchant()
			pass
		IGameServer.EffectFragmentType.UPDATE_STATE:
			var state_id : int = fragment.data[0]
			var param = fragment.data[1]
			_states[state_id].change_parameter(param)
			update_label_enchant()
			pass
		IGameServer.EffectFragmentType.DELETE_STATE:
			var state_id : int = fragment.data
			_states.erase(state_id)
			update_label_enchant()
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

	


func fix_select_card(card : Card3D):
	await _hand_area.fix_select_card(card)


func update_label_enchant():
	var lines : PackedStringArray = []
	for s in _states.values():
		var e := s as Enchantment
		lines.append(e.title)
	if lines.is_empty():
		%LabelEnchant.text = ""
		pass
#		%LabelEnchant.visible = false
	else:
		%LabelEnchant.text = "\n".join(lines)
#		%LabelEnchant.visible = true

