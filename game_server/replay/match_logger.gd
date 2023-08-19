
extends IGameServer

class_name MatchLogger

var server : IGameServer

var match_log : MatchLog



func _init():
	pass

func initialize(target_server : IGameServer):
	terminalize()
	server = target_server
	server.recieved_end.connect(_on_GameServer_recieved_end)
	server.recieved_first_data.connect(_on_GameServer_recieved_first_data)
	server.recieved_combat_result.connect(_on_GameServer_recieved_combat_result)
	server.recieved_recovery_result.connect(_on_GameServer_recieved_recovery_result)

	match_log = MatchLog.new()

func terminalize():
	if server:
		server.recieved_end.disconnect(_on_GameServer_recieved_end)
		server.recieved_first_data.disconnect(_on_GameServer_recieved_first_data)
		server.recieved_combat_result.disconnect(_on_GameServer_recieved_combat_result)
		server.recieved_recovery_result.disconnect(_on_GameServer_recieved_recovery_result)
		server = null
	


#


func _get_primary_data() -> PrimaryData:
	match_log.set_primary_data(server._get_primary_data())
	return match_log.primary_data


func _send_ready():
	server._send_ready()

func _send_combat_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	match_log.add_send_select(round_count,index,hands_order)
	server._send_combat_select(round_count,index,hands_order)

func _send_recovery_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	match_log.add_send_select(round_count,index,hands_order)
	server._send_recovery_select(round_count,index,hands_order)

func _send_surrender():
	server._send_surrender()


func _on_GameServer_recieved_end(msg:String)->void:
	match_log.set_end_msg(msg)
	recieved_end.emit(msg)

func _on_GameServer_recieved_first_data(data:FirstData)->void:
	match_log.set_first_data(data)
	recieved_first_data.emit(data)

func _on_GameServer_recieved_combat_result(data:CombatData)->void:
	match_log.add_combat_data(data)
	recieved_combat_result.emit(data)
	
func _on_GameServer_recieved_recovery_result(data:RecoveryData)->void:
	match_log.add_recovery_data(data)
	recieved_recovery_result.emit(data)


