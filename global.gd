extends Node


var catalog_factory : CatalogFactory
var card_catalog : CardCatalog

var game_settings := GameSettings.new()

var basic_deck_list : DeckList

func _init():
	catalog_factory = CatalogFactory.new()
	card_catalog = catalog_factory.basic_catalog

	basic_deck_list = DeckList.new("user://basic_deck.json",catalog_factory)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_settings.load_config()
	pass

func _unhandled_input(event : InputEvent):
	var key := event as InputEventKey
	if key and key.keycode == KEY_P and key.pressed:
		get_tree().paused = !get_tree().paused
