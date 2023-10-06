extends SceneChanger.IScene

var _scene_changer : SceneChanger


@onready var story : StoryScreen = $Story

const Tutorial = preload("res://game_client/tutorial/story_script.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

	
func _initialize(_changer : SceneChanger,_param : Array):
	_scene_changer = _changer
	pass
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass



func _on_button_1_pressed():
	const Tutorial1_Battle = preload("res://external_data/tutorial_data/t1_battle_script.gd")
	
	var scenario_path := "res://external_data/tutorial_data/1.txt"

	var translation := TranslationServer.get_locale()
	var code := translation.split("_")
	var language := "en" if code.is_empty() else code[0]
	if language != "ja":
		scenario_path =  "res://external_data/tutorial_data/1_%s.txt" % language
		if not FileAccess.file_exists(scenario_path):
			scenario_path =  "res://external_data/tutorial_data/1_en.txt"
	
	var tutorial1_battle_scenario = load(scenario_path)
	$Menu.hide()
	var script := Tutorial.new(Tutorial1_Battle.new(story.controller,tutorial1_battle_scenario.text))
	script.player_deck = PackedInt32Array([1,2,4,3,3,3,3])
	script.player_hand = 1
	script.enemy_data.hp = 3
	script.enemy_data.deck_list = [1,3,3,1,1,1]
	await story.start_async(script)
	
	$Menu.show()
	pass # Replace with function body.

func _on_button_2_pressed():
	const Tutorial2_Battle = preload("res://external_data/tutorial_data/t2_battle_script.gd")
	const tutorial2_battle_scenario = preload("res://external_data/tutorial_data/2.txt")
	$Menu.hide()
	var script := Tutorial.new(Tutorial2_Battle.new(story.controller,tutorial2_battle_scenario.text))
	script.player_deck = PackedInt32Array([6,6,5,7,6])
	script.player_hand = 1
	script.enemy_data.hp = 5
	script.enemy_data.deck_list = [4,8,4,3,1]
	await story.start_async(script)
	$Menu.show()

func _on_button_3_pressed():
	const Tutorial3_Battle = preload("res://external_data/tutorial_data/t3_battle_script.gd")
	const tutorial3_battle_scenario = preload("res://external_data/tutorial_data/3.txt")
	$Menu.hide()
	var script := Tutorial.new(Tutorial3_Battle.new(story.controller,tutorial3_battle_scenario.text))
	script.player_deck = PackedInt32Array([6,6,5,7,6])
	script.player_hand = 1
	script.enemy_data.hp = 5
	script.enemy_data.deck_list = [4,8,4,3,1]
	await story.start_async(script)
	$Menu.show()

	
func _on_button_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])

