


const skill : Dictionary = {
	1:Reinforce,
	2:Pierce,
	3:Charge,
	4:Isolate,
}

const enchantment : Dictionary = {
}
const ability : Dictionary = {
}


static func create_log(index : int, priority:int,fragments :Array[IGameServer.EffectFragment]) -> IGameServer.EffectLog:
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SKILL,index,priority,fragments)

class Reinforce extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _before_priority() -> Array:
		return [PRIORITY]
	func _before_effect(_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:

		var effect := _skill.parameter[0] as PackedInt32Array
		var stats := myself._get_card_stats(myself._get_playing_card_id())
		stats[0] += effect[0]
		stats[1] += effect[1]
		stats[2] += effect[2]
		var fragment := myself._change_combat_card_stats(stats,false)
		return SkillProcessor.create_log(_skill.index,PRIORITY,[fragment])


class Pierce extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _after_priority() -> Array:
		return [PRIORITY]
	func _after_effect(_priority : int,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		if myself._has_initiative() and not rival._has_initiative():
			@warning_ignore("integer_division")
			var damage := (rival._get_current_block() + 1) / 2
			if damage == 0:
				return SkillProcessor.create_log(_skill.index,PRIORITY,[])
			var fragment := rival._add_damage(damage,true)
			return SkillProcessor.create_log(_skill.index,PRIORITY,[fragment])
		return SkillProcessor.create_log(_skill.index,PRIORITY,[])


class Charge extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _end_priority() -> Array:
		return [PRIORITY]
	func _end_effect(_priority : int,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		if myself._get_damage() == 0:
			var effect := _skill.parameter[0] as PackedInt32Array
			var fragment := myself._create_enchant(myself._get_card_factory(),EnchantmentProcessor.Reinforce.DATA_ID,[effect],rival,false)
			return SkillProcessor.create_log(_skill.index,PRIORITY,[fragment])
		return SkillProcessor.create_log(_skill.index,PRIORITY,[])
		
class Isolate extends MechanicsData.BasicSkill:
	const PRIORITY = 255
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _moment_priority() -> Array:
		return [PRIORITY]
	func _moment_effect(_priority : int,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		var fragments : Array[IGameServer.EffectFragment] = []
		fragments.append(myself._add_damage(1,false))
		fragments.append(myself._set_initiative(false,false))
		fragments.append(rival._set_initiative(false,true))
		return SkillProcessor.create_log(_skill.index,PRIORITY,fragments)

