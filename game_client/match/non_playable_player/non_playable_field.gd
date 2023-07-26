extends Node3D


const Card3D_Scene := preload("res://game_client/match/card3d.tscn")

@onready var deck_position = $DeckPosition
@onready var hand_area = $HandArea
@onready var card_holder = $CardHolder


var _deck : Array[Card3D]

var _hand : PackedInt32Array = []
var _played : PackedInt32Array = []
var _discard : PackedInt32Array = []
var _stock_count : int
var _life : int = 0
var _damage : int = 0

var _states : Dictionary = {}

var _playing_card_id : int = -1

var _player_name : String



func initialize(player_name:String,deck : PackedInt32Array,catalog : CardCatalog,opponent : bool):
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
	_playing_card_id = -1
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
		cards.append(_deck[h])
	hand_area.set_cards(cards)
	hand_area.move_card(1)
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


