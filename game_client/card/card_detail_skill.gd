extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(skill : CatalogData.CardSkill):
	$VBoxContainer/HBoxContainer/Label.text = skill.title
	
	var skill_text := skill.text
	for e in skill.data.enchants:
		skill_text = skill_text.replace("{:%s}" % e.name,"[url]%s[/url]" % e.name)
	
	var pattern := RegEx.create_from_string("{([^}]+)}")
	skill_text = pattern.sub(skill_text,"[color=#d00]$1[/color]",true)
	
	$VBoxContainer/RichTextLabel.text = skill_text
	
	if skill.condition & CatalogData.ColorCondition.VS_FLAG:
		%ColorRectLeft.visible = true
		%ColorRectRight.visible = false
		%ColorRectLeft.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	elif skill.condition & CatalogData.ColorCondition.LINK_FLAG:
		%ColorRectLeft.visible = false
		%ColorRectRight.visible = true
		%ColorRectRight.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	else:
		%ColorRectLeft.visible = false
		%ColorRectRight.visible = false
	
	
