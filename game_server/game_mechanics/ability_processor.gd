class_name AbilityProcessor

static func create_log(index : int, priority:int,fragments :Array[IGameServer.EffectFragment]) -> IGameServer.EffectLog:
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.ABILITY,index,priority,fragments)

class AngerCounter extends MechanicsData.IAbility:
	var _data : CatalogData.CardAbility
	func _init(data : CatalogData.CardAbility):
		_data = data

	func _get_type() -> CatalogData.AbilityType:
		return _data.data.type

	func _effect(_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		_data.parameter
		return null
