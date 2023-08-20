
extends I_CardCatalog

class_name CardCatalog



var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}
var _ability_catalog : Dictionary = {}
var _enchant_catalog : Dictionary = {}

var _param_names : Array[CatalogData.ParameterName] = []


var version : String


func _init():
	load_catalog()

func load_catalog():
	_load_param_names()
	_load_enchant_data()
	_load_ability_data()
	_load_skill_data()
	_load_card_data()
	

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func _get_card_data(id : int) -> CatalogData.CardData:
	return _card_catalog[id]

func _get_enchantment_data(id : int) -> CatalogData.EnchantmentData:
	return _enchant_catalog[id]


func _get_skill_data(id : int) -> CatalogData.SkillData:
	return _skill_catalog[id]
	
func _get_ability_data(id : int) -> CatalogData.AbilityData:
	return _ability_catalog[id]


func get_param_name(param_type : int) -> CatalogData.ParameterName:
	return _param_names[param_type]

func _parse_card_skill(skill_string : String,index : int) -> CatalogData.CardSkill:
	var skill = skill_string.split(":");
	var condition : int = int(skill[0])
	var data := _get_skill_data(int(skill[1]))
	var params := []
	var skill_params : PackedStringArray = skill[2].split(",")
	var text := data.text
	for i in data.param_type.size():
		var param_string : String = ""
		match data.param_type[i]:
			CatalogData.ParamType.VOID:
				pass
			CatalogData.ParamType.INTEGER:
				var integer : int = int(skill_params[i])
				params.append(integer)
				param_string = param_to_string(CatalogData.ParamType.INTEGER,integer)
			CatalogData.ParamType.STATS:
				var stats : PackedInt32Array = [0,0,0]
				var stats_strings := skill_params[i].split(" ")
				stats[0] = int(stats_strings[0])
				stats[1] = int(stats_strings[1])
				stats[2] = int(stats_strings[2])
				params.append(stats)
				param_string = param_to_string(CatalogData.ParamType.STATS,stats)
			CatalogData.ParamType.COLOR:
				var color := int(skill_params[i])
				params.append(color)
				param_string = param_to_string(CatalogData.ParamType.COLOR,color)
			_:
				assert(false)
		if not param_string.is_empty():
			var replace_string : String = "{" + data.param_name[i] + "}"
			text = text.replace(replace_string,"{%s}" % param_string)

	var param_string := params_to_string(data.param_type,params)
	var title := data.name + ("" if param_string.is_empty() else "(" + param_string + ")")
	return CatalogData.CardSkill.new(index,data,condition,params,title,text)


func params_to_string(param_type : PackedInt32Array,param : Array) -> String:
	var param_string : PackedStringArray = []
	for i in param_type.size():
		var s := param_to_string(param_type[i],param[i])
		if not s.is_empty():
			param_string.append(s)
	return ",".join(param_string)

func param_to_string(param_type : int,param) -> String:
	match param_type:
		CatalogData.ParamType.INTEGER:
			var integer : int = param
			return str(integer)
		CatalogData.ParamType.STATS:
			var stats : PackedInt32Array = param
			var stats_names : PackedStringArray = []
			var stats_table := _param_names[CatalogData.ParamType.STATS].names
			for j in 3:
				if stats[j] != 0:
					stats_names.append(stats_table[j] + "%+d" % stats[j])
			return " ".join(stats_names)
		CatalogData.ParamType.COLOR:
			var color : int = param
			return _param_names[CatalogData.ParamType.COLOR].names[color]
	return ""


func _load_card_data():
	var carddata_resource := load("res://card_data/card_catalog.txt")
	var cards := (carddata_resource.text as String).split("\n")
	for c in cards:
		var tsv := c.split("\t")
		var id := int(tsv[0])
		var name := tsv[1]
		var rname := tsv[2]
		var skills : Array[CatalogData.CardSkill] = []
		var skill_texts := tsv[8].split(";")
		if skill_texts.size() == 1 and skill_texts[0] == "":
			skill_texts.resize(0)
		for i in skill_texts.size():
			skills.append(_parse_card_skill(skill_texts[i],i))
		var abilities : Array[CatalogData.AbilityData] = []
		var ability_texts := tsv[9].split(";")
		if ability_texts.size() == 1 and ability_texts[0] == "":
			ability_texts.resize(0)
		for i in ability_texts.size():
			abilities.append(_get_ability_data(int(ability_texts[i])))
		
		var text = tsv[10].replace("\\n","\n")
		var image = "res://card_images/"+ tsv[11] +".png"
		_card_catalog[id] = CatalogData.CardData.new(id,name,rname,
				int(tsv[3]),int(tsv[4]),int(tsv[5]),int(tsv[6]),int(tsv[7]),
				skills,abilities,text,image)
	version = (_card_catalog[0] as CatalogData.CardData).name
# warning-ignore:return_value_discarded
	_card_catalog.erase(0)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/card_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/card_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _card_catalog[id] as CatalogData.CardData
			data.name = tsv[1]
			data.ruby_name = data.name
			data.text = tsv[2].replace("\\n","\n")


func _load_skill_data():
	var namedskill_resource := load("res://card_data/skill_catalog.txt")
	var namedskills := (namedskill_resource.text as String).split("\n")
	for s in namedskills:
		var tsv := s.split("\t")
		var id := int(tsv[0])
		var name := tsv[1]
		var rname := tsv[2]
		var param_type : PackedInt32Array = Array(tsv[3].split(","))
		var param_name : PackedStringArray = []
		if param_type.size() == 1 and param_type[0] == CatalogData.ParamType.VOID:
			param_type = []
		else:
			param_name = tsv[4].split(",")
		var enchants_strings : PackedStringArray = tsv[5].split(",")
		var enchants : Array[CatalogData.EnchantmentData] = []
		if not (enchants_strings.size() == 1 and enchants_strings[0].is_empty()):
			for i in enchants_strings:
				enchants.append(_enchant_catalog[int(i)])
		var text = tsv[6].replace("\\n","\n")
		_skill_catalog[id] = CatalogData.SkillData.new(id,name,rname,param_type,param_name,enchants,text)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/skill_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/skill_en.txt")
		var trans = (trans_res.text as String).split("\n")
		for i in trans.size():
			var tsv := trans[i].split("\t")
			var id := int(tsv[0])
			var data := _skill_catalog[id] as CatalogData.SkillData
			data.name = tsv[1]
			data.ruby_name = data.name
			if not data.param_name.is_empty():
				data.param_name = tsv[2].split(",")
			data.text = tsv[3].replace("\\n","\n")

func _load_ability_data():
	var ability_resource := load("res://card_data/ability_catalog.txt")
	var abilities := (ability_resource.text as String).split("\n")
	for s in abilities:
		var tsv := s.split("\t")
		var id := int(tsv[0])
		var name := tsv[1]
		var rname := tsv[2]
		var enchants_strings : PackedStringArray = tsv[3].split(",")
		var enchants : Array[CatalogData.EnchantmentData] = []
		if not (enchants_strings.size() == 1 and enchants_strings[0].is_empty()):
			for i in enchants_strings:
				enchants.append(_enchant_catalog[int(i)])
		var text = tsv[4].replace("\\n","\n")
		_ability_catalog[id] = CatalogData.AbilityData.new(id,name,rname,enchants,text)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/ability_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/ability_en.txt")
		var trans := (trans_res.text as String).split("\n")
		for i in trans.size():
			var tsv := trans[i].split("\t")
			var id := int(tsv[0])
			var data := _ability_catalog[id] as CatalogData.AbilityData
			data.name = tsv[1]
			data.ruby_name = data.name
			data.text = tsv[2].replace("\\n","\n")


func _load_enchant_data():
	var enchant_resource := load("res://card_data/enchant_catalog.txt")
	var enchants := (enchant_resource.text as String).split("\n")
	for s in enchants:
		var tsv := s.split("\t")
		var id := int(tsv[0])
		var name := tsv[1]
		var rname := tsv[2]
		var param_type : PackedInt32Array = Array(tsv[3].split(","))
		var param_name : PackedStringArray = []
		if not tsv[5].is_empty():
			param_name = tsv[4].split(",")
		var text = tsv[5].replace("\\n","\n")
		_enchant_catalog[id] = CatalogData.EnchantmentData.new(id,name,rname,param_type,param_name,text)
	
	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/enchant_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/enchant_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data := _enchant_catalog[id] as CatalogData.EnchantmentData
			data.name = tsv[1]
			data.ruby_name = data.name
			if not data.param_name.is_empty():
				data.param_name = tsv[2].split(",")
			data.text = tsv[3].replace("\\n","\n")



func _load_param_names():
	var param_names_resource := preload("res://card_data/param_name_catalog.txt")
	var param_names := (param_names_resource.text as String).split("\n")
	_param_names.resize(param_names.size())
	for s in param_names:
		var tsv := s.split("\t")
		if tsv.size() < 3:
			continue
		var id := int(tsv[0])
		_param_names[id] = CatalogData.ParameterName.new(id,tsv[2])
		
	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/param_name_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/param_name_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			_param_names[id] = CatalogData.ParameterName.new(id,tsv[2])
			
