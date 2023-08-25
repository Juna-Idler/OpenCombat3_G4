extends Node

var card_catalog := CardCatalog.new()

var game_settings := GameSettings.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_settings.load_config()
	pass

func _unhandled_input(event : InputEvent):
	var key := event as InputEventKey
	if key and key.keycode == KEY_P and key.pressed:
		get_tree().paused = !get_tree().paused
