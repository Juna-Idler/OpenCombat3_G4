
class_name StateProcessor

static func create_log(id : int, priority:int,fragments :Array[IGameServer.EffectFragment]) -> IGameServer.EffectLog:
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.STATE,id,priority,fragments)


class Reinforce extends MechanicsData.BasicState:
	const DATA_ID = 1
	const PRIORITY = 1
	var _stats : PackedInt32Array
	
	func _get_data_id() -> int:
		return DATA_ID
	
	func _init(match_id:int,param : Array,_attached : IPlayer,_opponent : IPlayer):
		super(match_id)
		_stats = param[0]

	func _before_priority() -> Array:
		return [PRIORITY]
	func _before_effect(_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		var stats := myself._get_card_stats(myself._get_playing_card_id())
		stats[0] += _stats[0]
		stats[1] += _stats[1]
		stats[2] += _stats[2]
		var fragment := myself._change_combat_card_stats(stats,false)
		var fragment2 := myself._delete_state(self,false)
		return StateProcessor.create_log(_match_id,PRIORITY,[fragment,fragment2])

