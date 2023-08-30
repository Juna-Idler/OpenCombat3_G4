extends HBoxContainer

const CardDetailSkill := preload("res://game_client/card/card_detail_skill.tscn")
const CardDetailSkillEnchant := preload("res://game_client/card/card_detail_skill_enchant.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(cd : CatalogData.CardData,
		c : CatalogData.CardColors,l : int,p : int,h : int,b : int,
		skills : Array[CatalogData.CardSkill],pict : Texture2D):
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	
	$CardFront.initialize(cd.name,c,l,p,h,b,skills,pict)
	for s in skills:
		var skill_detail := CardDetailSkill.instantiate()
		skill_detail.initialize(s)
		$ScrollContainer/VBoxContainer.add_child(skill_detail)
		for st in s.data.enchants:
			var st_label : RichTextLabel = CardDetailSkillEnchant.instantiate()
			var st_param := "" if st.param_name.is_empty() else ("(" + ",".join(st.param_name) + ")")
			st_label.text = st.name + st_param + "\n" + st.text
			$ScrollContainer/VBoxContainer.add_child(st_label)

func initialize_origin(cd : CatalogData.CardData):
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	
	$CardFront.initialize(cd.name,cd.color,cd.level,cd.power,cd.hit,cd.block,cd.skills,load(cd.image))
	for s in cd.skills:
		var skill_detail := CardDetailSkill.instantiate()
		skill_detail.initialize(s)
		$ScrollContainer/VBoxContainer.add_child(skill_detail)
		for st in s.data.enchants:
			var st_label : RichTextLabel = CardDetailSkillEnchant.instantiate()
			var st_param := "" if st.param_name.is_empty() else ("(" + ",".join(st.param_name) + ")")
			st_label.text = st.name + st_param + "\n" + st.text
			$ScrollContainer/VBoxContainer.add_child(st_label)
