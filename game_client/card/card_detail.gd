extends HBoxContainer

const CardDetailSkill := preload("res://game_client/card/card_detail_skill.tscn")
const CardDetailSkillEnchant := preload("res://game_client/card/card_detail_skill_enchant.tscn")
const CardDetailAbility := preload("res://game_client/card/card_detail_ability.tscn")
const CardDetailText := preload("res://game_client/card/card_detail_text.tscn")


@onready var card_detail_container = %CardDetailContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(cd : CatalogData.CardData,
		c : CatalogData.CardColors,l : int,p : int,h : int,b : int,
		skills : Array[CatalogData.CardSkill],pict : Texture2D):
	for child in card_detail_container.get_children():
		card_detail_container.remove_child(child)
		child.queue_free()
	
	$CardFront.initialize(cd.name,c,l,p,h,b,skills,pict)
	
	$VBoxContainer/PanelContainer/RubyLabelName.text_input = cd.ruby_name
	var color := Global.card_catalog.param_to_string(CatalogData.ParamType.COLOR,c)
	$VBoxContainer/LabelStats.text = "%s %d/%d/%d %d" % [color,p,h,b,l]

	var enchants := {}
	add_skill(skills,enchants)
	add_ability(cd.abilities,enchants)
	add_flavor_text(cd.text)
	


func initialize_origin(cd : CatalogData.CardData):
	for child in card_detail_container.get_children():
		card_detail_container.remove_child(child)
		child.queue_free()
	
	$VBoxContainer/PanelContainer/RubyLabelName.text_input = cd.ruby_name
	var color := Global.card_catalog.param_to_string(CatalogData.ParamType.COLOR,cd.color)
	$VBoxContainer/LabelStats.text = "%s %d/%d/%d %d" % [color,cd.power,cd.hit,cd.block,cd.level]
	
	$CardFront.initialize(cd.name,cd.color,cd.level,cd.power,cd.hit,cd.block,cd.skills,load(cd.image))
	var enchants := {}
	add_skill(cd.skills,enchants)
	add_ability(cd.abilities,enchants)
	add_flavor_text(cd.text)


func add_skill(skills : Array[CatalogData.CardSkill],enchants : Dictionary):
	for s in skills:
		var skill_detail := CardDetailSkill.instantiate()
		skill_detail.initialize(s)
		card_detail_container.add_child(skill_detail)
		for e in s.data.enchants:
			if enchants.has(e.name):
				continue
			var enc_detail : RichTextLabel = CardDetailSkillEnchant.instantiate()
			var enc_param := "" if e.param_name.is_empty() else ("(" + ",".join(e.param_name) + ")")
			enc_detail.text = e.name + enc_param + "\n" + e.text
			card_detail_container.add_child(enc_detail)
			enchants[e.name] = enc_detail

func add_ability(abilities : Array[CatalogData.AbilityData],enchants : Dictionary):
	for a in abilities:
		var ability_detail : RichTextLabel = CardDetailAbility.instantiate()
		var a_text := a.text
		for e in a.enchants:
			a_text = a_text.replace("{:%s}" % e.name,"[url]%s[/url]" % e.name)
		ability_detail.text = "Ability:" + a.name + "\n" + a_text
		card_detail_container.add_child(ability_detail)
		for e in a.enchants:
			if enchants.has(e.name):
				continue
			var enc_detail : RichTextLabel = CardDetailSkillEnchant.instantiate()
			var enc_param := "" if e.param_name.is_empty() else ("(" + ",".join(e.param_name) + ")")
			enc_detail.text = e.name + enc_param + "\n" + e.text
			card_detail_container.add_child(enc_detail)
			enchants[e.name] = enc_detail

func add_flavor_text(text : String):
	var label : RichTextLabel = CardDetailText.instantiate()
	label.text = "[center]" + text + "[/center]"
	card_detail_container.add_child(label)

