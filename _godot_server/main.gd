extends Node


@export var port_number = 14739

@onready var websocket_server : WebsocketServer = $WebsocketServer

var _version : String


var _card_factory : PlayerCardFactory


class ClientData:
	var client_id : int
	var name : String
	var catalog : String
	var deck : PackedInt32Array
	var regulation : String
	var select : int = -1
	var remain_time : float = 0
	
	func _init(id : int,n : String,c : String,d : PackedInt32Array,r : String):
		client_id = id
		name = n
		catalog = c
		deck = d
		regulation = r

class GameRoom:
	static var websocket_server : WebsocketServer
	var game : GameProcessor
	var game_player1 : StandardPlayer
	var game_player2 : StandardPlayer
	var card_factory : PlayerCardFactory
	
	var player1 : ClientData
	var player2 : ClientData
	var starting_time : float

	func _init(p1 : ClientData,p2 : ClientData,factory : PlayerCardFactory):
		game = GameProcessor.new()
		player1 = p1
		player2 = p2
		card_factory = factory
		game_player1 = StandardPlayer.new(card_factory,player1.deck,4,true)
		game_player2 = StandardPlayer.new(card_factory,player2.deck,4,true)
		
		var pd1 := IGameServer.PrimaryData.new(player1.name,player1.deck,player1.catalog,
				player2.name,player2.deck,player2.catalog,player1.regulation,"")
		var pd2 := IGameServer.PrimaryData.new(player2.name,player2.deck,player2.catalog,
				player1.name,player1.deck,player1.catalog,player1.regulation,"")
		var p1_json := JSON.stringify({"type":"Primary","data":pd1.serialize()})
		var p2_json := JSON.stringify({"type":"Primary","data":pd2.serialize()})
		websocket_server.send(player1.client_id,p1_json)
		websocket_server.send(player2.client_id,p2_json)
	
	func receive_ready(client_id : int):
		if player1.client_id == client_id:
			player1.select = 1
		if player2.client_id == client_id:
			player2.select = 1
		if player1.select > 0 and player2.select > 0:
			var first := game.standby(game_player1,game_player2)
			var serialized_data := first.serialize()
			var p1_first := JSON.stringify({"type":"First","data":serialized_data})
			var swap = serialized_data["m"]
			serialized_data["m"] = serialized_data["r"]
			serialized_data["r"] = swap
			var p2_first := JSON.stringify({"type":"First","data":serialized_data})
			websocket_server.send(player1.client_id,p1_first)
			websocket_server.send(player2.client_id,p2_first)
			player1.select = -1
			player2.select = -1
			
	func receive_combat_select(client_id : int,
			round_count:int,index:int,hands_order:PackedInt32Array):
		if game.phase != IGameServer.Phase.COMBAT or game.round_count != round_count:
			return

		if client_id == player1.client_id:
			player1.select = index
			game.reorder_hand1(hands_order)
		elif client_id == player2.client_id:
			player2.select = index
			game.reorder_hand2(hands_order)
			
		if player1.select > 0 and player2.select > 0:
			var data := game.combat(player1.select,player2.select)
			var serialized_data := data.serialize()
			var p1_json := JSON.stringify({"type":"Combat","data":serialized_data})
			var swap = serialized_data["m"]
			serialized_data["m"] = serialized_data["r"]
			serialized_data["r"] = swap
			var p2_json := JSON.stringify({"type":"Combat","data":serialized_data})
			
			player1.select = -1
			player2.select = -1

			websocket_server.send(player1.client_id,p1_json)
			websocket_server.send(player2.client_id,p2_json)

	func receive_recovery_select(client_id : int,
			round_count:int,index:int,hands_order:PackedInt32Array):
		if game.phase != IGameServer.Phase.RECOVERY or game.round_count != round_count:
			return

		if client_id == player1.client_id:
			player1.select = index
			game.reorder_hand1(hands_order)
		elif client_id == player2.client_id:
			player2.select = index
			game.reorder_hand2(hands_order)
			
		if (player1.select > 0 or game_player1._is_recovery()) and (player2.select > 0 or game_player2._is_recovery()):
			var data := game.recover(player1.select,player2.select)
			var serialized_data := data.serialize()
			var p1_json := JSON.stringify({"type":"Recovery","data":serialized_data})
			var swap = serialized_data["m"]
			serialized_data["m"] = serialized_data["r"]
			serialized_data["r"] = swap
			var p2_json := JSON.stringify({"type":"Recovery","data":serialized_data})
			
			player1.select = -1
			player2.select = -1

			websocket_server.send(player1.client_id,p1_json)
			websocket_server.send(player2.client_id,p2_json)

	func receive_surrender(client_id : int):
		if player1.client_id == client_id:
			websocket_server.send(player1.client_id,JSON.stringify({"type":"End","data":{"msg":"you surrender"}}))
			websocket_server.send(player2.client_id,JSON.stringify({"type":"End","data":{"msg":"rival surrender"}}))
		elif player2.client_id == client_id:
			websocket_server.send(player2.client_id,JSON.stringify({"type":"End","data":{"msg":"you surrender"}}))
			websocket_server.send(player1.client_id,JSON.stringify({"type":"End","data":{"msg":"rival surrender"}}))

	func socket_disconnect(client_id : int):
		if player1.client_id == client_id:
			websocket_server.send(player2.client_id,JSON.stringify({"type":"End","data":{"msg":"rival disconnect"}}))
			pass
		elif player2.client_id == client_id:
			websocket_server.send(player1.client_id,JSON.stringify({"type":"End","data":{"msg":"rival disconnect"}}))
			pass
	
	func terminalize():
		websocket_server.send(player1.client_id,JSON.stringify({"type":"End","data":{"msg":"server error"}}))
		websocket_server.send(player2.client_id,JSON.stringify({"type":"End","data":{"msg":"server error"}}))


func _init():
	_card_factory = PlayerCardFactory.new(Global.card_catalog)

var wait : ClientData
var match_users : Dictionary # client_id : GameRoom
var match_rooms : Dictionary # of GameRoom


# Called when the node enters the scene tree for the first time.
func _ready():
	websocket_server.listen(port_number,"127.0.0.1")
	GameRoom.websocket_server = websocket_server
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_websocket_server_connected(_client_id : int):
	pass # Replace with function body.


func _on_websocket_server_disconnected(_client_id : int):
	pass # Replace with function body.


func _on_websocket_server_received(client_id : int, message : String):
	var dic = JSON.parse_string(message)
	var type : String = dic.get("type")
	var data : Dictionary = dic.get("data")
	
	print(type + str(client_id))

	match type:
		"Version":
			var _ver := data["version"] as String
			var send_dic := {
				"type":"Version",
				"data":{
					"version":_version
				}
			 }
			websocket_server.send(client_id,JSON.stringify(send_dic))

		"Match":
			var p_name := data["n"] as String
			var catalog := data["c"] as String
			var deck := data["d"] as PackedInt32Array
			var reg := data["r"] as String
			
			var client := ClientData.new(client_id,p_name,catalog,deck,reg)
			
			if wait != null and websocket_server.client_opened(wait.client_id):
				print("Match:" + str(client_id) + "&" + str(wait.client_id))
				var room := GameRoom.new(wait,client,_card_factory)
				match_users[wait.client_id] = room
				match_users[client_id] = room
				wait = null

				
			else:
				wait = client

		"Ready":
			if match_users.has(client_id):
				(match_users[client_id] as GameRoom).receive_ready(client_id)
			
		"Select":
			var p := data["p"] as String
			var rc := data["r"] as int
			var i := data["i"] as int
			var ho := data["h"] as PackedInt32Array
			if match_users.has(client_id):
				match p:
					"C":
						(match_users.get(client_id) as GameRoom).receive_combat_select(client_id,rc,i,ho)
					"R":
						(match_users.get(client_id) as GameRoom).receive_recovery_select(client_id,rc,i,ho)
		
		"End":
			if match_users.has(client_id):
				var room := match_users.get(client_id) as GameRoom
				match_users.erase(room.player1.client_id)
				match_users.erase(room.player2.client_id)

				room.receive_surrender(client_id)
			elif wait != null and wait.client_id == client_id:
				wait = null
	
	pass # Replace with function body.
