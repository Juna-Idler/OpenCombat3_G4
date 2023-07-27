extends Node3D


const Card3D_Scene := preload("res://game_client/match/card3d.tscn")


@onready var deck_position = $DeckPosition
@onready var card_holder = $CardHolder
var _hand_area : HandArea = null


var _deck : Array[Card3D]

var _hand : PackedInt32Array = [] # of int
var _played : PackedInt32Array = [] # of int
var _discard : PackedInt32Array = [] # of int
var _stock_count : int
var _life : int = 0
var _damage : int = 0

var _states : Dictionary = {} # of MatchEffect.IState

var _playing_card : Card3D = null

var _player_name : String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(hand_area : HandArea,
		player_name:String,deck : PackedInt32Array,catalog : CardCatalog,opponent : bool):
	
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
	
	if opponent:
		rotation_degrees.z = 180
		$CanvasLayer/Control/CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT,Control.PRESET_MODE_MINSIZE)
		$CanvasLayer/Control/LabelName.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_KEEP_SIZE)



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
		IGameServer.EffectFragmentType.DAMAGE:
			var damage : int = fragment.data[0]
			var block : int = fragment.data[1]
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
			var card : int = fragment.data
			pass
		IGameServer.EffectFragmentType.DISCARD:
			var card : int = fragment.data
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
			pass
		IGameServer.EffectFragmentType.UPDATE_STATE:
			var state_id : int = fragment.data[0]
			var param = fragment.data[1]
			pass
		IGameServer.EffectFragmentType.DELETE_STATE:
			var state_id : int = fragment.data
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
	return


func fix_select_card(card : Card3D):
	await _hand_area.fix_select_card(card)

