extends "res://utility_code/clickable_control.gd"

var _deck_data : DeckData

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(deck_data : DeckData):
	_deck_data = deck_data
	$LabelName.text = _deck_data.name
	var levels := _deck_data.get_level_count()
	$LabelInfo.text = "Cards:%d Cost:%d Level:%d/%d/%d" % [
		_deck_data.get_cards_count(),
		_deck_data.get_total_cost(),
		levels[1],
		levels[2],
		levels[3]
	]

func get_deck() -> DeckData:
	return _deck_data

func set_border_color(c : Color):
	self_modulate = c
	

