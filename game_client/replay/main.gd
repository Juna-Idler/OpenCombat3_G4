extends SceneChanger.IScene

var _scene_changer : SceneChanger

var replay_server := ReplayServer.new()

var catalog := CardCatalog.new()

const NonPlayablePlayerFieldScene := preload("res://game_client/match/player/field/non_playable_field.tscn")


var myself : NonPlayablePlayerField
var rival : NonPlayablePlayerField



func _ready():
	pass
#	initialize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	%Settings.hide()
	
#	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,34,35,35]
#	var pile : Array[int] = [35,34,34,34]
	
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	myself = NonPlayablePlayerFieldScene.instantiate()
	
	rival = NonPlayablePlayerFieldScene.instantiate()
	
#	replay_server.initialize("",pile,ICpuCommander.ZeroCommander.new(),pile,d,m,catalog)
	$match_scene.initialize(replay_server,myself,rival,catalog,catalog)
	if not $match_scene.performed.is_connected(on_match_scene_performed):
		$match_scene.performed.connect(on_match_scene_performed)
	if not $match_scene.ended.is_connected(on_match_scene_ended):
		$match_scene.ended.connect(on_match_scene_ended)
		
func _fade_in_finished():
	replay_server._send_ready()
	pass



func on_match_scene_performed():
	if $match_scene.phase == IGameServer.Phase.GAME_END:
		pass
	
func on_match_scene_ended(msg : String):
	pass



func _on_button_settings_pressed():
	%Settings.show()


