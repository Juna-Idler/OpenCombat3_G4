class_name AbilityProcessor

class AngerCounter:
	static func effect(myself : MechanicsData.IPlayer,rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
		var fragments : Array[IGameServer.EffectFragment] = []
		fragments.append(myself._create_enchant(myself._get_card_factory(),EnchantmentProcessor.AngerCounter.DATA_ID,[0],rival,false))
		return fragments


