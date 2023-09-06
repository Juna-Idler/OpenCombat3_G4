extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = $SubViewport.get_texture()
	pass # Replace with function body.


func initialize(skill : CatalogData.CardSkill,opponent : bool):
	$SubViewport/Panel/Label.text = skill.title

	if skill.condition & CatalogData.ColorCondition.VS_FLAG:
		$SubViewport/Panel/ColorRectCounter.visible = true
		$SubViewport/Panel/ColorRectLink.visible = false
		var color : int = skill.condition & CatalogData.ColorCondition.COLOR_BITS
		$SubViewport/Panel/ColorRectCounter.color = CatalogData.RGB[color]
	elif skill.condition & CatalogData.ColorCondition.LINK_FLAG:
		$SubViewport/Panel/ColorRectCounter.visible = false
		$SubViewport/Panel/ColorRectLink.visible = true
		var color : int = skill.condition & CatalogData.ColorCondition.COLOR_BITS
		$SubViewport/Panel/ColorRectLink.color = CatalogData.RGB[color]
	else:
		$SubViewport/Panel/ColorRectCounter.visible = false
		$SubViewport/Panel/ColorRectLink.visible = false

	if opponent:
		$SubViewport/Panel/Label.rotation_degrees = 180

	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	
