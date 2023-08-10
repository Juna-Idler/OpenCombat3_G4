extends Node

var server := OfflineServer.new()
var catalog := CardCatalog.new()

const PlayablePlayerFieldScene := preload("res://game_client/match/player/field/playable_field.tscn")
const NonPlayablePlayerFieldScene := preload("res://game_client/match/player/field/non_playable_field.tscn")


var myself : PlayablePlayerField
var rival : NonPlayablePlayerField


func _ready():
	initialize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initialize():
	$CanvasLayer/Control/ButtonGameOver.hide()
	$CanvasLayer/Control/Label.hide()
	
#	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
#	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,28,29,30,32,33,34]
	var pile : Array[int] = [34,34,34,34]
	
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	myself = PlayablePlayerFieldScene.instantiate()
	myself.hand_selected.connect(on_hand_selected)
	
	rival = NonPlayablePlayerFieldScene.instantiate()
	
	server.initialize("",pile,ICpuCommander.ZeroCommander.new(),pile,d,m,catalog)
	$match_scene.initialize(server,myself,rival,catalog,catalog)
	if not $match_scene.performed.is_connected(on_match_scene_performed):
		$match_scene.performed.connect(on_match_scene_performed)
	server._send_ready()


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
	if server.non_playable_recovery_phase:
		server._send_recovery_select($match_scene.round_count,-1)
		return
	if $match_scene.phase != IGameServer.Phase.GAME_END:
		myself.hand_area.set_playable(true)
	else:
		$CanvasLayer/Control/ButtonGameOver.show()
		$CanvasLayer/Control/Label.show()
		var mp : int = $match_scene.my_game_end_point
		var rp : int = $match_scene.rival_game_end_point
		
		if mp > rp:
			$CanvasLayer/Control/Label.text = "You Win %d:%d" % [mp,rp]
		elif mp < rp:
			$CanvasLayer/Control/Label.text = "You Lose %d:%d" % [mp,rp]
		else:
			$CanvasLayer/Control/Label.text = "Draw %d:%d" % [mp,rp]
			pass
	


func _on_button_game_over_pressed():
	initialize()
	pass # Replace with function body.
