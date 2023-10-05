
class_name EnemyCommonBehavior


class EnchantmentInexhaustible extends MechanicsData.BasicEnchantment:
	const DATA_ID = 100
	const PRIORITY = 1
	
	var deck : Array[int]
	var first : bool = true
	
	func _get_data_id() -> int:
		return DATA_ID
	
	func _init(match_id:int,_param : Array,attached : IPlayer,_opponent : IPlayer):
		super(match_id)
#		deck.assign(attached._get_deck_list().map(func(v):return v.data.id))
	
	func _start_priority() -> Array:
		return [PRIORITY]
	func _start_effect(_priority : int,
			myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		if first:
			var list := myself._get_deck_list().map(func(v):return v.data.id)
			var discard := myself._get_discard().duplicate()
			discard.sort()
			discard.reverse()
			for i in discard:
				list.remove_at(i)
			deck.assign(list)
			first = false
			return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
			
		var fragments : Array[IGameServer.EffectFragment] = []
		if myself._get_stock_count() == 0:
			deck.shuffle()
			for i in deck:
				fragments.append(myself._create_card(myself._get_card_factory(),i,-1,{}))
			return IGameServer.EffectLog.new(IGameServer.EffectSourceType.ENCHANTMENT,
					_match_id,PRIORITY,fragments)
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])

class AbilityInexhaustible:
	const DATA_ID = 100
	static func effect(card_deck_id : PackedInt32Array,
			myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
		var fragments : Array[IGameServer.EffectFragment] = []
		fragments.append(myself._create_enchant(myself._get_card_factory(),
				EnchantmentInexhaustible.DATA_ID,[],rival,false))
		for i in card_deck_id:
			fragments.append(myself._discard_card(i,false,true))
		return fragments

var enchantment_inexhaustible := CatalogData.EnchantmentData.new(
		EnchantmentInexhaustible.DATA_ID,"無尽蔵","",[],[],"")

var ability_inexhaustible := CatalogData.AbilityData.new(
		AbilityInexhaustible.DATA_ID,"無尽蔵","",[enchantment_inexhaustible],"")

func set_catalog(enchant_catalog : Dictionary,ability_catalog : Dictionary):
	enchant_catalog[EnchantmentInexhaustible.DATA_ID] = enchantment_inexhaustible
	ability_catalog[AbilityInexhaustible.DATA_ID] = ability_inexhaustible

static func set_factory(enchant_factory : Dictionary,ability_factory : Dictionary):
	enchant_factory[EnchantmentInexhaustible.DATA_ID] = EnchantmentInexhaustible
	ability_factory[AbilityInexhaustible.DATA_ID] = AbilityInexhaustible
