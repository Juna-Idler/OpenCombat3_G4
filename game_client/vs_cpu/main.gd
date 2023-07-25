extends Node

var server := OfflineServer.new()
var catalog := CardCatalog.new()

var myself := PlayablePlayer.new()
var rival := NonPlayablePlayer.new()



func _ready():
	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]	
	
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	server.initialize("",pile,ICpuCommander.ZeroCommander.new(),pile,d,m,catalog)
	$match_scene.initialize(server,catalog,catalog,myself,rival)
	
	server._send_ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
