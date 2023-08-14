extends SceneChanger.IScene


var _scene_changer : SceneChanger

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass

func _on_button_pressed():
	_scene_changer.goto_scene("res://game_client/vs_cpu/main.tscn",[])
