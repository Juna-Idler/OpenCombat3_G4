extends I_CardCatalog


var card_data : CatalogData.CardData

var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}
var _ability_catalog : Dictionary = {}
var _enchant_catalog : Dictionary = {}


func _init():
	var common := EnemyCommonBehavior.new()
	common.set_catalog(_enchant_catalog,_ability_catalog)
	
	_card_catalog[1] = CatalogData.CardData.new(1,"なにもしない","",
			CatalogData.CardColors.NOCOLOR,0,0,0,1,
			[],[],"なにもしない","")
	
	_card_catalog[2] = CatalogData.CardData.new(2,"無尽蔵","",
			CatalogData.CardColors.NOCOLOR,0,0,0,0,
			[],[_ability_catalog[EnemyCommonBehavior.AbilityInexhaustible.DATA_ID]],"無尽蔵","")

	


func _get_catalog_name() -> String:
	return "Enemy Dummy"

func _get_card_data(id : int) -> CatalogData.CardData:
	return _card_catalog.get(id)

func _get_enchantment_data(id : int) -> CatalogData.EnchantmentData:
	return _enchant_catalog.get(id)

func _get_skill_data(id : int) -> CatalogData.SkillData:
	return _skill_catalog.get(id)

func _get_ability_data(id : int) -> CatalogData.AbilityData:
	return _ability_catalog.get(id)


func _get_card_id_list() -> PackedInt32Array:
	return _card_catalog.keys()

