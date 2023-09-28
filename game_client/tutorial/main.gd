extends SceneChanger.IScene

var _scene_changer : SceneChanger


@onready var story : StoryScreen = $Story

const Tutorial = preload("res://game_client/tutorial/story_script.gd")
const Tutorial1_Battle = preload("res://game_client/tutorial/t1_battle_script.gd")
const tutorial1_battle_scenario = preload("res://game_client/tutorial/1.txt")

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
	$Menu.hide()
	var script := Tutorial.new(Tutorial1_Battle.new(story.controller,tutorial1_battle_scenario.text))
	await story.start_async(script)
	
	$Menu.show()
	pass # Replace with function body.


func _on_button_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])
