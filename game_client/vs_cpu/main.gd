extends Node

var server := OfflineServer.new()
var catalog := CardCatalog.new()

var myself := PlayablePlayer.new()
var rival := NonPlayablePlayer.new()



func _ready():
	myself.hand_selected.connect(on_hand_selected)
	
	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]	
	
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	server.initialize("",pile,ICpuCommander.ZeroCommander.new(),pile,d,m,catalog)
	$match_scene.initialize(server,catalog,catalog,myself,rival)
	$match_scene.performed.connect(on_match_scene_performed)
	server._send_ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_hand_selected(index : int,hand : Array[Card3D]):
	myself._hand_area.set_playable(false)
	var order : PackedInt32Array = []
	for h in hand:
		order.append(h.id_in_deck)
	match $match_scene.phase:
		IGameServer.Phase.COMBAT:
			server._send_combat_select($match_scene.round_count,index,order)
			pass
		IGameServer.Phase.RECOVERY:
			server._send_recovery_select($match_scene.round_count,index,order)
			pass
		IGameServer.Phase.GAME_END:
			pass
	await myself.fix_select_card(hand[index])
	pass

func on_match_scene_performed():
	if $match_scene.phase != IGameServer.Phase.GAME_END:
		myself._hand_area.set_playable(true)
	
