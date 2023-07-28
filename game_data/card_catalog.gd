
extends I_CardCatalog

class_name CardCatalog



var _card_catalog : Dictionary = {}
var _skill_catalog : Dictionary = {}
var _state_catalog : Dictionary = {}

var _param_names : Array[CatalogData.ParameterName] = []


var version : String


func _init():
#	translation = TranslationServer.get_locale()
	
	load_catalog()

func load_catalog():
	_load_param_names()
	_load_state_data()
	_load_skill_data()
	_load_card_data()
	

func get_max_card_id() -> int:
	return _card_catalog.size() - 1

func _get_card_data(id : int) -> CatalogData.CardData:
	return _card_catalog[id]

func _get_state_data(id : int) -> CatalogData.StateData:
	return _state_catalog[id]


func get_skill_data(id : int) -> CatalogData.SkillData:
	return _skill_catalog[id]

func get_param_name(param_type : int) -> CatalogData.ParameterName:
	return _param_names[param_type]

func _parse_card_skill(skill_string : String,index : int) -> CatalogData.CardSkill:
	var skill = skill_string.split(":");
	var condition : int = int(skill[0])
	var data := get_skill_data(int(skill[1]))
	var params := []
	var skill_params : PackedStringArray = skill[2].split(",")
	for i in data.param_type.size():
		match data.param_type[i]:
			CatalogData.ParamType.INTEGER:
				var integer : int = int(skill_params[i])
				params.append(integer)
			CatalogData.ParamType.STATS:
				var stats := [0,0,0]
				for e in skill_params[i].split(" "):
					if e.find("P") == 0:
						stats[0] = int(e.substr("P".length()))
					elif e.find("H") == 0:
						stats[1] = int(e.substr("H".length()))
					elif e.find("B") == 0:
						stats[2] = int(e.substr("B".length()))
				params.append(stats)
			CatalogData.ParamType.COLOR:
				var color := int(skill_params[i])
				params.append(color)
	var param_string := param_to_string(data.param_type,params)
	var title := data.name + ("" if param_string.is_empty() else "(" + param_string + ")")
	return CatalogData.CardSkill.new(index,data,condition,params,title)
		

func param_to_string(param_type : PackedInt32Array,param : Array) -> String:
	var param_string : PackedStringArray = []
	for i in param_type.size():
		match param_type[i]:
			CatalogData.ParamType.INTEGER:
				var integer : int = param[i]
				param_string.append(str(integer))
			CatalogData.ParamType.STATS:
				var stats : PackedInt32Array = param[i]
				var stats_names : PackedStringArray = []
				var stats_table := _param_names[CatalogData.ParamType.STATS].names
				for j in 3:
					if stats[j] != 0:
						stats_names.append(stats_table[j] + "%+d" % stats[j])
				param_string.append(" ".join(stats_names))
			CatalogData.ParamType.COLOR:
				var color : int = param[i]
				param_string.append(_param_names[CatalogData.ParamType.COLOR].names[color])
	return ",".join(param_string)


func _load_card_data():
	var carddata_resource := load("res://card_data/card_data_catalog.txt")
	var cards = carddata_resource.text.split("\n")
	for c in cards:
		var tsv = c.split("\t")
		var skills : Array[CatalogData.CardSkill] = []
		var skill_texts = tsv[9].split(";")
		if skill_texts.size() == 1 and skill_texts[0] == "":
			skill_texts.resize(0)
		for i in skill_texts.size():
			skills.append(_parse_card_skill(skill_texts[i],i))
		var id := int(tsv[0])
		var text = tsv[10].replace("\\n","\n")
		var image = "res://card_images/"+ tsv[11] +".png"
		_card_catalog[id] = CatalogData.CardData.new(id,tsv[1],tsv[3],
				int(tsv[4]),int(tsv[5]),int(tsv[6]),int(tsv[7]),int(tsv[8]),
				skills,text,image)
	version = (_card_catalog[0] as CatalogData.CardData).name
# warning-ignore:return_value_discarded
	_card_catalog.erase(0)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/card_data_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/card_data_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _card_catalog[id] as CatalogData.CardData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			data.text = tsv[3].replace("\\n","\n")


func _load_skill_data():
	var namedskill_resource := load("res://card_data/named_skill_catalog.txt")
	var namedskills = namedskill_resource.text.split("\n")
	for s in namedskills:
		var tsv = s.split("\t")
		var id := int(tsv[0])
		var text = tsv[7].replace("\\n","\n")

		var states_strings : PackedStringArray = tsv[6].split(",")
		var states : Array[CatalogData.StateData] = []
		if not (states_strings.size() == 1 and states_strings[0].is_empty()):
			for i in states_strings:
				states.append(_state_catalog[int(i)])
		
		var param_type : PackedInt32Array = Array(tsv[4].split(","))
		var param_name : PackedStringArray = []
		if param_type.size() == 1 and param_type[0] == CatalogData.ParamType.VOID:
			param_type = []
		else:
			param_name = tsv[5].split(",")
		_skill_catalog[id] = CatalogData.SkillData.new(id,tsv[1],tsv[3],param_type,param_name,states,text)

	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/named_skill_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/named_skill_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _skill_catalog[id] as CatalogData.SkillData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			if not data.parameter.empty():
				data.parameter = tsv[3].split(",")
			data.text = tsv[4].replace("\\n","\n")


func _load_state_data():
	var state_resource := load("res://card_data/state_catalog.txt")
	var states = state_resource.text.split("\n")
	for s in states:
		var tsv = s.split("\t")
		var id := int(tsv[0])
		var param_type : PackedInt32Array = Array(tsv[4].split(","))
		var param_name : PackedStringArray = []
		if not tsv[5].is_empty():
			param_name = tsv[5].split(",")
		var text = tsv[6].replace("\\n","\n")
		_state_catalog[id] = CatalogData.StateData.new(id,tsv[1],tsv[3],param_type,param_name,text)
	
	var translation := TranslationServer.get_locale()
	if translation.find("ja") != 0:
		var trans_res = load("res://card_data/state_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/state_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			var data = _state_catalog[id] as CatalogData.StateData
			data.name = tsv[1]
			data.short_name = tsv[2]
			data.ruby_name = ""
			if not data.parameter.empty():
				data.parameter = tsv[3].split(",")
			data.text = tsv[4].replace("\\n","\n")



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
		var trans_res = load("res://card_data/attribute_" + translation + ".txt")
		if not trans_res:
			trans_res = load("res://card_data/attribute_en.txt")
		var trans = trans_res.text.split("\n")
		for i in trans.size():
			var tsv = trans[i].split("\t")
			var id := int(tsv[0])
			_param_names[id] = CatalogData.ParameterName.new(id,tsv[2])
			
