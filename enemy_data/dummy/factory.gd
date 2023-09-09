extends MechanicsData.ICardFactory

var _card_catalog : I_CardCatalog = preload("res://enemy_data/dummy/catalog.gd").new()


var _enchant_factory : Dictionary = {}
var _ability_factory : Dictionary = {}

func _init():
	EnemyCommonBehavior.set_factory(_enchant_factory,_ability_factory)


func _get_catalog() -> I_CardCatalog:
	return _card_catalog


func _create(iid : int,data_id : int) -> MechanicsData.Card:
	var card_data := _card_catalog._get_card_data(data_id)
	var skills : Array[MechanicsData.ISkill] = []
	for s in card_data.skills:
		skills.append(_create_skill(s))
	return MechanicsData.Card.new(iid,card_data,skills)
		

func _create_skill(_skill : CatalogData.CardSkill) -> MechanicsData.ISkill:
	return null
func _create_enchant(enchant_id : int,data_id : int,param : Array,
		attached : IPlayer,opponent : IPlayer) -> MechanicsData.IEnchantment:
	return _enchant_factory[data_id].new(enchant_id,param,attached,opponent)

func _ability_behavior(data_id : int,myself : MechanicsData.IPlayer,
		rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
	return _ability_factory[data_id].effect(myself,rival)
	


