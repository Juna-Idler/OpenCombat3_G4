
class_name SkillProcessor

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

		var effect := _skill.parameter[0].data as PackedInt32Array
		var stats := myself._get_card_stats(myself._get_playing_card_id())
		stats[0] += effect[0]
		stats[1] += effect[1]
		stats[2] += effect[2]
		var fragment := myself._change_card_stats(myself._get_playing_card_id(),stats,false)
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
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		if myself._get_damage() == 0:
			var effect := _skill.parameter[0].data as PackedInt32Array
			var fragment := myself._create_state(myself._get_card_factory(),StateProcessor.Reinforce.DATA_ID,[effect],false)
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

class Absorb extends MechanicsData.BasicSkill:
	const PRIORITY = 1
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _before_priority() -> Array:
		return [PRIORITY]
	func _before_effect(_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		var level := 0
		var fragments : Array[IGameServer.EffectFragment] = []
		for h in myself._get_hand():
			var card := myself._get_deck_list()[h]
			if card.data.color == _skill.parameter[0].data:
				level = card.data.level
				fragments.append(myself._discard_card(h))
				fragments.append(myself._draw_card())
				break

		var stats := myself._get_card_stats(myself._get_playing_card_id())
		var effect := _skill.parameter[1].data as PackedInt32Array
		stats[0] += effect[0] * level
		stats[1] += effect[1] * level
		stats[2] += effect[2] * level
		fragments.append(myself._change_card_stats(myself._get_playing_card_id(),stats,false))
		return SkillProcessor.create_log(_skill.index,PRIORITY,fragments)


class BlowAway extends MechanicsData.BasicSkill:
	const PRIORITY = 4
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _after_priority() -> Array:
		return [PRIORITY]
	func _after_effect(_priority : int,
			_myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		var count := _skill.parameter[0].data as int

		var fragments : Array[IGameServer.EffectFragment] = []
		for i in count:
			fragments.append(rival._bounce_card(rival._get_hand()[0],0,true))
			fragments.append(rival._draw_card(true))
		return SkillProcessor.create_log(_skill.index,PRIORITY,fragments)


class Attract extends MechanicsData.BasicSkill:
	const PRIORITY = 3
	func _init(data : CatalogData.CardSkill):
		super(data)
		pass
	
	func _after_priority() -> Array:
		return [PRIORITY]
	func _after_effect(_priority : int,
			myself : MechanicsData.IPlayer,_rival : MechanicsData.IPlayer) -> IGameServer.EffectLog:
		var count := _skill.parameter[0].data as int
		var fragments : Array[IGameServer.EffectFragment] = []
		for i in count:
			fragments.append(myself._bounce_card(myself._get_hand()[0],0))
			fragments.append(myself._draw_card())
		return SkillProcessor.create_log(_skill.index,PRIORITY,fragments)

