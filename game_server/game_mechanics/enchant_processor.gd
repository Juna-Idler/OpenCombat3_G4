
class_name EnchantmentProcessor

static func create_log(id : int, priority:int,fragments :Array[IGameServer.EffectFragment]) -> IGameServer.EffectLog:
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.ENCHANTMENT,id,priority,fragments)


class Reinforce extends MechanicsData.BasicEnchantment:
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
		var fragment2 := myself._delete_enchant(self,false)
		return EnchantmentProcessor.create_log(_match_id,PRIORITY,[fragment,fragment2])


class AngerCounter extends MechanicsData.BasicEnchantment:
	const DATA_ID = 2
	var _counter : int
	var _attached : IPlayer
	
	func _get_data_id() -> int:
		return DATA_ID
	func _get_parameter() -> Array:
		return [_counter]
	
	func _init(match_id:int,param : Array,attached : IPlayer,_opponent : IPlayer):
		super(match_id)
		_counter = param[0]
		_attached = attached
		_attached.passive_discarded.connect(on_passive_discarded)

	func _term() -> void:
		_attached.passive_discarded.disconnect(on_passive_discarded)

	func on_passive_discarded(_card:int,add_log : Callable):
		_counter += 1
		var plog := IGameServer.PassiveLog.new(false,_match_id,[_counter])
		add_log.call(plog)

