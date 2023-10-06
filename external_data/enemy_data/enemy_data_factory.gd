
class_name EnemyDataFactory

const ENEMY_DATA_DIR := "res://external_data/enemy_data/"

static func create(name : String) -> EnemyData:
	var dir_path := ENEMY_DATA_DIR.path_join(name)
	var catalog_path := dir_path.path_join("catalog.json")
	var behavior_path := dir_path.path_join("behavior.gd")
	
	var json_text := FileAccess.get_file_as_string(catalog_path)
	var json = JSON.parse_string(json_text)
	var enemy = json["Enemy"]
	var enemy_name : String = enemy["name"]
	var enemy_rname : String = enemy["ruby_name"]
	var enemy_text : String = enemy["text"]
	
	var translation := TranslationServer.get_locale()
	var code := translation.split("_")
	var language := "en" if code.is_empty() else code[0]
	var tr_catalog : TranslationCatalog = null
	if language != "ja":
		var res = load(dir_path.path_join("catalog_%s.txt" % language))
		if not res:
			res = load(dir_path.path_join("catalog_en.txt"))
		tr_catalog = TranslationCatalog.new(res.text)
		enemy_name = tr_catalog.enemy_data.name
		enemy_rname = tr_catalog.enemy_data.ruby_name
		enemy_text = tr_catalog.enemy_data.text
	
	var catalog := EnemyCatalog.new(name,json,tr_catalog)
	
	var behavior := load(behavior_path)
	var factory := EnemyCardFactory.new(catalog,behavior.skill,behavior.enchantment,behavior.ability)
	
	var image := load(dir_path.path_join("image.png"))
	return EnemyData.new(enemy_name,enemy_rname,enemy_text,
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

	func _ability_behavior(data_id : int,card_deck_id : PackedInt32Array,
			myself : MechanicsData.IPlayer,
			rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
		return ability_behaviors[data_id].effect(card_deck_id,myself,rival)
		


class EnemyCatalog extends I_CardCatalog:
	var catalog_name : String
	var card_catalog : Dictionary = {}
	var skill_catalog : Dictionary = {}
	var ability_catalog : Dictionary = {}
	var enchant_catalog : Dictionary = {}
	
	func _init(c_name : String,json : Dictionary,translation : TranslationCatalog = null):
		if not (json.has("Cards") and json.has("Skills") and
				json.has("Abilities") and json.has("Enchantments")):
			return
		catalog_name = c_name
		for e in json.get("Enchantments"):
			var id : int = e["id"]
			var name : String = e["name"]
			var rname : String = e["ruby_name"]
			var text : String = e["text"]
			if translation:
				var data : TranslationData = translation.enchant_catalog[id]
				name = data.name
				rname = data.ruby_name
				text = data.text

			enchant_catalog[id] = CatalogData.EnchantmentData.new(id,
					name,rname,e["param_type"],e["parameter"],text)
					
		for a in json.get("Abilities"):
			var id : int = a["id"]
			var name : String = a["name"]
			var rname : String = a["ruby_name"]
			var text : String = a["text"]
			if translation:
				var data : TranslationData = translation.ability_catalog[id]
				name = data.name
				rname = data.ruby_name
				text = data.text
			var enchants : Array[CatalogData.EnchantmentData] = []
			enchants.assign(a["enchants"].map(func(e : int):return enchant_catalog[e]))
			ability_catalog[id] = CatalogData.AbilityData.new(id,
					name,rname,enchants,text)
					
		for s in json.get("Skills"):
			var id : int = s["id"]
			var name : String = s["name"]
			var rname : String = s["ruby_name"]
			var text : String = s["text"]
			if translation:
				var data : TranslationData = translation.skill_catalog[id]
				name = data.name
				rname = data.ruby_name
				text = data.text
			var enchants : Array[CatalogData.EnchantmentData] = []
			enchants.assign(s["enchants"].map(func(e : int):return enchant_catalog[e]))
			skill_catalog[id] = CatalogData.SkillData.new(id,
					name,rname,s["param_type"],s["parameter"],enchants,text)
		
		for c in json.get("Cards"):
			var id : int = c["id"]
			var name : String = c["name"]
			var rname : String = c["ruby_name"]
			var text : String = c["text"]
			if translation:
				var data : TranslationData = translation.card_catalog[id]
				name = data.name
				rname = data.ruby_name
				text = data.text
			var skills : Array[CatalogData.CardSkill] = []
			var i : int = -1
			skills.assign(c["skills"].map(func(s):
				i += 1
				return Global.card_catalog.parse_card_skill(s,i,skill_catalog)
			))
			var abilities : Array[CatalogData.AbilityData] = []
			abilities.assign(c["abilities"].map(func(a : int):return ability_catalog[a]))
			var image_path := ENEMY_DATA_DIR.path_join(catalog_name).path_join(str(id) + ".png")
			card_catalog[id] = CatalogData.CardData.new(id,name,rname,
					int(c["color"]),int(c["level"]),int(c["power"]),int(c["hit"]),int(c["block"]),
					skills,abilities,text,image_path)

		
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



class TranslationCatalog:
	var enemy_data : TranslationData
	var card_catalog : Dictionary = {}
	var skill_catalog : Dictionary = {}
	var ability_catalog : Dictionary = {}
	var enchant_catalog : Dictionary = {}

	func _init(tsv : String):
		var line := tsv.split("\n")
		var mode := ""
		const modes : PackedStringArray = ["ENEMY_ID","CARD_ID","SKILL_ID","ABILITY_ID","ENCHANT_ID"]
		for l in line:
			if l.is_empty():
				continue
			var cell := l.split("\t")
			if cell[0].is_empty():
				continue
			if cell[0] == "END":
				break
			if modes.has(cell[0]):
				mode = cell[0]
				continue
			var id := int(cell[0])
			var data := TranslationData.new(id,cell[1],cell[2],cell[3])
			match mode:
				"ENEMY_ID":
					enemy_data = data
				"CARD_ID":
					card_catalog[id] = data
				"SKILL_ID":
					skill_catalog[id] = data
				"ABILITY_ID":
					ability_catalog[id] = data
				"ENCHANT_ID":
					enchant_catalog[id] = data

class TranslationData:
	var id : int
	var name : String
	var ruby_name : String
	var text : String
	
	func _init(i : int,n : String,rn : String,t : String):
		id = i
		name = n
		ruby_name = rn
		text = t

