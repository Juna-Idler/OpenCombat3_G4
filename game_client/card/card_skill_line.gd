extends ColorRect

class_name CardSkillLine


func _ready():
	pass

func initialize(skill : CatalogData.CardSkill,opponent : bool = false):
	$Label.text = skill.title

	if skill.condition & CatalogData.ColorCondition.VS_FLAG:
		$ColorRectRight.visible = false
		$ColorRectLeft.visible = true
		$ColorRectLeft.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	elif skill.condition & CatalogData.ColorCondition.LINK_FLAG:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = true
		$ColorRectRight.color = CatalogData.RGB[skill.condition & CatalogData.ColorCondition.COLOR_BITS]
	else:
		$ColorRectLeft.visible = false
		$ColorRectRight.visible = false
	
	if opponent:
		$Label.rotation_degrees = 180
