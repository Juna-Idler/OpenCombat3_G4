extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(skill : CatalogData.CardSkill):
	$VBoxContainer/HBoxContainer/Label.text = skill.title
	$VBoxContainer/RichTextLabel.text = skill.text
	
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
	
	
