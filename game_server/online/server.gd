extends IGameServer

class_name OnlineServer

signal connected(version_match : bool)
signal matched(data : PrimaryData)
signal disconnected


var _socket : WebsocketClient

var _primary_data : IGameServer.PrimaryData

var _version : String
var _server_version : String

var playable : bool = false

func _init(socket : WebsocketClient,version : String):
	_version = version
	_socket = socket
	_socket.received.connect(on_websocket_received)
	_socket.connected.connect(on_websocket_connected)
	pass
	
func on_websocket_connected():
	var dic := {
		"type":"Version",
		"data":{
			"version":_version
		}
	 }
	_socket.send(JSON.stringify(dic))


func send_match(player_name :String,catalog_name : String, deck :PackedInt32Array, regulation :String):
	var dic := {
		"type":"Match",
		"data":{
			"n":player_name,
			"c":catalog_name,
			"d":deck,
			"r":regulation,
		}
	}
	_socket.send(JSON.stringify(dic))



func _get_primary_data() -> PrimaryData:
	return _primary_data

func _send_ready():
	var dic : Dictionary = {
		"type" : "Ready",
		"data" : {
		}
	}
	_socket.send(JSON.stringify(dic))


func _send_combat_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	var dic : Dictionary = {
		"type" : "Select",
		"data" : {
			"p":"C",
			"r":round_count,
			"i":index,
			"h":hands_order,
		}
	}
	_socket.send(JSON.stringify(dic))
	
func _send_recovery_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	var dic : Dictionary = {
		"type" : "Select",
		"data" : {
			"p":"R",
			"r":round_count,
			"i":index,
			"h":hands_order,
		}
	}
	_socket.send(JSON.stringify(dic))
	
func _send_surrender():
	var dic := {
		"type":"End",
		"data":{
			"msg":"surrender"
		}
	}
	_socket.send(JSON.stringify(dic))


func on_websocket_received(message : String):
	var dic = JSON.parse_string(message) as Dictionary
	if dic == null:
		return
	var type : String = dic.get("type")
	var data : Dictionary = dic.get("data")
	if type == null or data == null:
		return
		
	match type:
		"Version":
			playable = false
			_server_version = data.get("version","")
			connected.emit(_version == _server_version)

		"Primary":
			playable = false
			_primary_data = IGameServer.PrimaryData.deserialize(data)
			matched.emit(_primary_data)

		"First":
			playable = true
			var first := IGameServer.FirstData.deserialize(data)
			recieved_first_data.emit(first)
		
		"Combat":
			var combat := IGameServer.CombatData.deserialize(data)
			if (combat.next_phase == IGameServer.Phase.COMBAT or
					(combat.next_phase == IGameServer.Phase.RECOVERY and combat.myself.damage > 0)):
				playable = true
			else:
				playable = false

			recieved_combat_result.emit(combat)
				
		"Recovery":
			var recovery := IGameServer.RecoveryData.deserialize(data)
			if (recovery.next_phase == IGameServer.Phase.COMBAT or
					(recovery.next_phase == IGameServer.Phase.RECOVERY and recovery.myself.damage > 0)):
				playable = true
			else:
				playable = false
			recieved_recovery_result.emit(recovery)
				
		"End":
			playable = false
			var msg := data["msg"] as String
			recieved_end.emit(msg)
				
	
