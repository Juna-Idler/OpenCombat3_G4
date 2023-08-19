
class_name MatchLog


class TimedUpdateData:
	var time : int
	var phase : IGameServer.Phase
	var data# : IGameServer.CombatData or RecoveryData
	func _init(t,p,d):
		time = t
		phase = p
		data = d

	func serialize() -> Dictionary:
		if phase == IGameServer.Phase.COMBAT:
			var cd := (data as IGameServer.CombatData)
			return {"t":time,"p":phase,"d":cd.serialize()}
		else:
			var rd := (data as IGameServer.RecoveryData)
			return {"t":time,"p":phase,"d":rd.serialize()}

	static func deserialize(dic : Dictionary) -> TimedUpdateData:
		var t : int = dic["t"]
		var p : int = dic["p"]
		if p == IGameServer.Phase.COMBAT:
			return TimedUpdateData.new(t,p,IGameServer.CombatData.deserialize(dic["d"]))
		else:
			return TimedUpdateData.new(t,p,IGameServer.RecoveryData.deserialize(dic["d"]))


class TimedSendSelect:
	var time : int
	var round_count:int
	var index:int
	var hands_order:PackedInt32Array
	func _init(t,rc,i,h):
		time = t
		round_count = rc
		index = i
		hands_order = h
		

var datetime : String
var end_msg : String
var end_time : int
var primary_data : IGameServer.PrimaryData
var first_data : IGameServer.FirstData
var update_data : Array[TimedUpdateData]
var send_select : Array[TimedSendSelect]

var _first_time : int

func _init():
	primary_data = null
	first_data = null
	update_data = []
	send_select = []
	_first_time = 0
	end_time = -1

func set_end_msg(msg:String):
	if _first_time >= 0:
		end_time = Time.get_ticks_msec() - _first_time
		_first_time = -1
	end_msg = msg

func set_primary_data(data:IGameServer.PrimaryData):
	primary_data = data

func set_first_data(data:IGameServer.FirstData):
	datetime = Time.get_datetime_string_from_system(false,true)
	first_data = data
	_first_time = Time.get_ticks_msec()

func add_combat_data(data:IGameServer.CombatData):
	update_data.append(TimedUpdateData.new(Time.get_ticks_msec() - _first_time,IGameServer.Phase.COMBAT,data))
	if data.next_phase == IGameServer.Phase.GAME_END:
		_first_time = -1

func add_recovery_data(data:IGameServer.RecoveryData):
	update_data.append(TimedUpdateData.new(Time.get_ticks_msec() - _first_time,IGameServer.Phase.RECOVERY,data))
	if data.next_phase == IGameServer.Phase.GAME_END:
		_first_time = -1

func add_send_select(rc,i,ho):
	send_select.append(TimedSendSelect.new(Time.get_ticks_msec() - _first_time,rc,i,ho))


func serialize() -> Dictionary:
	return {
		"date":datetime,
		"end":{"msg":end_msg,"time":end_time},
		"pd":primary_data.serialize(),
		"fd":first_data.serialize(),
		"ud":update_data.map(func(v):return v.serialize())
	}

	
func deserialize(dic : Dictionary) -> void:
	datetime = dic["date"]
	end_msg = dic["end"]["msg"]
	end_time = dic["end"]["time"]
	primary_data = IGameServer.PrimaryData.deserialize(dic["pd"])
	first_data = IGameServer.FirstData.deserialize(dic["fd"])
	update_data = dic["ud"].map(func(v):return TimedUpdateData.deserialize(v))

