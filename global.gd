extends Node

var card_catalog := CardCatalog.new()

var replay_log : Array[MatchLog]

func _ready():
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func _unhandled_input(event : InputEvent):
	var key := event as InputEventKey
	if key and key.keycode == KEY_P and key.pressed:
		get_tree().paused = !get_tree().paused
