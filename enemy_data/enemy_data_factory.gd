
class_name EnemyDataFactory

const ENEMY_DATA_DIR := "res://enemy_data/"

static func create(name : String) -> EnemyData:
	var dir_path := ENEMY_DATA_DIR.path_join(name)
	var catalog_path := dir_path.path_join("catalog.json")
	var behavior_path := dir_path.path_join("behavior.gd")
	
	var json_text := FileAccess.get_file_as_string(catalog_path)
	var json = JSON.parse_string(json_text)
	var catalog := EnemyCatalog.new(name,json)
	
	var behavior := load(behavior_path)
	var factory := EnemyCardFactory.new(catalog,behavior.skill,behavior.enchantment,behavior.ability)
	
	var enemy = json["Enemy"]
	var image := load(dir_path.path_join("image.png"))
	return EnemyData.new(enemy["name"],enemy["ruby_name"],enemy["text"],
			enemy["hp"],image,enemy["list"],catalog,factory)


class EnemyCardFactory extends MechanicsData.ICardFactory:
	var card_catalog : I_CardCatalog = null

	var skill_behaviors : Dictionary = {}
	var enchant_behaviors : Dictionary = {}
	var ability_behaviors : Dictionary = {}

	func _init(catalog : I_CardCatalog,skill : Dictionary,enchant : Dictionary,ability : Dictionary):
		card_catalog = catalog
		skill_behaviors = skill
		enchant_behaviors = enchant
		ability_behaviors = ability


	func _get_catalog() -> I_CardCatalog:
		return card_catalog


	func _create(iid : int,data_id : int) -> MechanicsData.Card:
		var card_data := card_catalog._get_card_data(data_id)
		var skills : Array[MechanicsData.ISkill] = []
		for s in card_data.skills:
			skills.append(_create_skill(s))
		return MechanicsData.Card.new(iid,card_data,skills)

	func _create_skill(skill : CatalogData.CardSkill) -> MechanicsData.ISkill:
		return skill_behaviors[skill.data.id].new(skill)
		
	func _create_enchant(enchant_id : int,data_id : int,param : Array,
			attached : MechanicsData.IPlayer,opponent : MechanicsData.IPlayer) -> MechanicsData.IEnchantment:
		return enchant_behaviors[data_id].new(enchant_id,param,attached,opponent)

	func _ability_behavior(data_id : int,myself : MechanicsData.IPlayer,
			rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
		return ability_behaviors[data_id].effect(myself,rival)
		


class EnemyCatalog extends I_CardCatalog:
	var catalog_name : String
	var card_catalog : Dictionary = {}
	var skill_catalog : Dictionary = {}
	var ability_catalog : Dictionary = {}
	var enchant_catalog : Dictionary = {}
	
	func _init(name : String,json : Dictionary):
		if not (json.has("Cards") and json.has("Skills") and
				json.has("Abilities") and json.has("Enchantments")):
			return
		catalog_name = name
		for e in json.get("Enchantments"):
			var id : int = e["id"]
			enchant_catalog[id] = CatalogData.EnchantmentData.new(id,
					e["name"],e["ruby_name"],e["param_type"],e["parameter"],e["text"])
					
		for a in json.get("Abilities"):
			var id : int = a["id"]
			var enchants : Array[CatalogData.EnchantmentData] = []
			enchants.assign(a["enchants"].map(func(e : int):return enchant_catalog[e]))
			ability_catalog[id] = CatalogData.AbilityData.new(id,
					a["name"],a["ruby_name"],enchants,a["text"])
					
		for s in json.get("Skills"):
			var id : int = s["id"]
			var enchants : Array[CatalogData.EnchantmentData] = []
			enchants.assign(s["enchants"].map(func(e : int):return enchant_catalog[e]))
			skill_catalog[id] = CatalogData.SkillData.new(id,
					s["name"],s["ruby_name"],s["param_type"],s["parameter"],enchants,s["text"])
		
		for c in json.get("Cards"):
			var id : int = c["id"]
			var skills : Array[CatalogData.CardSkill] = []
			var i : int = -1
			skills.assign(c["skills"].map(func(s):
				i += 1
				return Global.card_catalog.parse_card_skill(s["catalog_string"],i,skill_catalog)
			))
			var abilities : Array[CatalogData.AbilityData] = []
			abilities.assign(c["abilities"].map(func(a : int):return ability_catalog[a]))
			var image_path := ENEMY_DATA_DIR.path_join(name).path_join(str(id) + ".png")
			card_catalog[id] = CatalogData.CardData.new(id,c["name"],c["ruby_name"],
					int(c["color"]),int(c["level"]),int(c["power"]),int(c["hit"]),int(c["block"]),
					skills,abilities,c["text"],image_path)

		
	func _get_catalog_name() -> String:
		return catalog_name

	func _get_card_data(id : int) -> CatalogData.CardData:
		return card_catalog.get(id)

	func _get_enchantment_data(id : int) -> CatalogData.EnchantmentData:
		return enchant_catalog.get(id)

	func _get_skill_data(id : int) -> CatalogData.SkillData:
		return skill_catalog.get(id)

	func _get_ability_data(id : int) -> CatalogData.AbilityData:
		return ability_catalog.get(id)

	func _get_card_id_list() -> PackedInt32Array:
		return card_catalog.keys()


