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
	
	_damage = 0
	_blocked_damage = 0
	%LabelBlock.text = str(0)
	%LabelDamage.text = str(0)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_playing_card,"position",$CombatPosition.position,0.5)
	_hand_area.move_card(0.5)
	await tween.finished
	return

func get_playing_card() -> Card3D:
	return _playing_card
	
	
func perform_effect(effect : IGameServer.EffectLog):
	match effect.type:
		IGameServer.EffectSourceType.SYSTEM_PROCESS:
			pass
		IGameServer.EffectSourceType.SKILL:
			var card := get_playing_card()
			card.skills[effect.id]
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
				await get_tree().create_timer(0.5).timeout
			if unblocked_damage > 0:
				$CombatPosition/AudioStreamPlayer3D.stream = preload("res://sounds/小パンチ.mp3")
			for d in unblocked_damage:
				_damage += 1
				var number : String = str(_damage)
				%LabelDamage.text = number
				$CombatPosition/AudioStreamPlayer3D.play()
				await get_tree().create_timer(0.5).timeout
			pass
		IGameServer.EffectFragmentType.INITIATIVE:
			var initiative : bool = fragment.data
			pass
		IGameServer.EffectFragmentType.CHANGE_STATS:
			var card : int = fragment.data[0]
			var power : int = fragment.data[1]
			var hit : int = fragment.data[2]
			var block : int = fragment.data[3]
			pass
		IGameServer.EffectFragmentType.DRAW_CARD:
			var card_id : int = fragment.data
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
			tween.tween_method(card.set_transparency,1.0,0.0,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
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

	
	
func combat_end() -> void:
	_played.append(_playing_card.id_in_deck)
	_playing_card.location = Card3D.CardLocation.PLAYED
	var pos : Vector3 = $PlayedPosition.position
	pos.z += 0.01 * _played.size()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	tween.tween_property(_playing_card,"position",pos,0.5)
	tween.tween_property(_playing_card,"rotation:z",-PI/2,0.5)
	_playing_card.tween = tween
	_playing_card = null
	await tween.finished
	
	%HBoxContainerDamage.visible = false
	
	return


func fix_select_card(card : Card3D):
	await _hand_area.fix_select_card(card)


func update_label_enchant():
	var lines : PackedStringArray = []
	for s in _states.values():
		var e := s as Enchantment
		lines.append(e.title)
	if lines.is_empty():
		%LabelEnchant.visible = false
	else:
		%LabelEnchant.text = "\n".join(lines)
		%LabelEnchant.visible = true

