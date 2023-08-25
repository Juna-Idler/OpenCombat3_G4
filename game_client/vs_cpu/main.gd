extends SceneChanger.IScene

var _scene_changer : SceneChanger

var offline_server := OfflineServer.new()
var logger := MatchLogger.new()

var server : IGameServer = null
var catalog := CardCatalog.new()

const PlayablePlayerFieldScene := preload("res://game_client/match/player/field/playable_field.tscn")
const NonPlayablePlayerFieldScene := preload("res://game_client/match/player/field/non_playable_field.tscn")


var myself : PlayablePlayerField
var rival : NonPlayablePlayerField




func _ready():
	pass
#	initialize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
#	seed(0)
	_scene_changer = changer
	$CanvasLayer/Control.hide()
	%Settings.hide()
	
#	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,34,35,35]
#	var pile : Array[int] = [35,34,34,34]
	
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	myself = PlayablePlayerFieldScene.instantiate()
	myself.hand_selected.connect(on_hand_selected)
	
	rival = NonPlayablePlayerFieldScene.instantiate()
	
	offline_server.initialize(Global.game_settings.player_name,pile,ICpuCommander.ZeroCommander.new(),pile,d,m,catalog)
	logger.initialize(offline_server)
	server = logger
	$match_scene.initialize(server,myself,rival,catalog,catalog)
	if not $match_scene.performed.is_connected(on_match_scene_performed):
		$match_scene.performed.connect(on_match_scene_performed)
	if not $match_scene.ended.is_connected(on_match_scene_ended):
		$match_scene.ended.connect(on_match_scene_ended)
		
func _fade_in_finished():
	server._send_ready()
	pass


func on_hand_selected(index : int,hand : Array[Card3D]):
	myself.hand_area.set_playable(false)
	var order : PackedInt32Array = []
	for h in hand:
		order.append(h.id_in_deck)
	match $match_scene.phase:
		IGameServer.Phase.COMBAT:
			server._send_combat_select($match_scene.round_count,index,order)
		IGameServer.Phase.RECOVERY:
			server._send_recovery_select($match_scene.round_count,index,order)
		IGameServer.Phase.GAME_END:
			pass
	await myself.fix_select_card(hand[index])
	pass

func on_match_scene_performed():
	if offline_server.non_playable_recovery_phase:
		server._send_recovery_select($match_scene.round_count,-1)
		return
	if $match_scene.phase != IGameServer.Phase.GAME_END:
		myself.hand_area.set_playable(true)
	else:
		if $CanvasLayer/Control.visible:
			return
		$CanvasLayer/Control.show()
		var mp : int = $match_scene.my_game_end_point
		var rp : int = $match_scene.rival_game_end_point
		
		if mp > rp:
			$CanvasLayer/Control/Label.text = "You Win %d:%d" % [mp,rp]
		elif mp < rp:
			$CanvasLayer/Control/Label.text = "You Lose %d:%d" % [mp,rp]
		else:
			$CanvasLayer/Control/Label.text = "Draw %d:%d" % [mp,rp]
			pass
		var time_string := "%.3f" % Time.get_unix_time_from_system()
		MatchLogFile.save("user://replay/" + time_string + ".replay_log",logger.match_log)
	
func on_match_scene_ended(msg : String):
		$CanvasLayer/Control.show()
		
		$CanvasLayer/Control/Label.text = "Game End:\n" + msg
		var time_string := "%.3f" % Time.get_unix_time_from_system()
		MatchLogFile.save("user://replay/" + time_string + ".replay_log",logger.match_log)
		


func _on_button_game_over_pressed():
	_initialize(_scene_changer,[])
	_fade_in_finished()
	pass # Replace with function body.


func _on_button_game_over_2_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])
	pass # Replace with function body.


func _on_button_settings_pressed():
	%Settings.show()


func _on_button_surrender_pressed():
	server._send_surrender()
	%Settings.hide()

