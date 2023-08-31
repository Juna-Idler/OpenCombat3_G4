extends SceneChanger.IScene


var _scene_changer : SceneChanger

# Called when the node enters the scene tree for the first time.
func _ready():
	var local := TranslationServer.get_locale()
	if local == "en":
		%LanguageOptionButton.selected = 1
	


func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass

func _on_button_pressed():
	_scene_changer.goto_scene("res://game_client/vs_cpu/main.tscn",[])


func _on_language_option_button_item_selected(index):
	match index:
		0:
			if TranslationServer.get_locale() != "ja":
				TranslationServer.set_locale("ja")
		1:
			if TranslationServer.get_locale() != "en":
				TranslationServer.set_locale("en")
	Global.card_catalog.load_catalog()

	
	pass # Replace with function body.


func _on_button_settings_pressed():
	$Settings.show()


func _on_button_2_pressed():
	_scene_changer.goto_scene("res://game_client/replay/main.tscn",[])
	pass # Replace with function body.


func _on_button_3_pressed():
	_scene_changer.goto_scene("res://game_client/deck_build/main.tscn",[])
