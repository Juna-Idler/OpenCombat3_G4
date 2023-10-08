extends Control

class ZeroCommander extends ICpuCommander:
	func _get_commander_name()-> String:
		return "ZeroCommander"



var server := OfflineServer.new()
var card_catalog := CardCatalog.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var dreg := RegulationData.DeckRegulation.new("",15,15,0,0,"1-30")
	var mreg := RegulationData.MatchRegulation.new("",4,120,10,5)
	
#	server.initialize("test",[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
#			ZeroCommander.new(),[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
#			dreg,mreg,card_catalog)
	
	server.recieved_first_data.connect(
			func(f : IGameServer.FirstData) :
				print(f.myself)
				)
	
	server._send_ready()
	
	server._send_combat_select(1,0)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
