extends Node2D

class_name EnchantmentTitle


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = $SubViewport.get_texture()
	pass # Replace with function body.


func initialize(title : String,opponent : bool):
	$SubViewport/Panel/Label.text = title

	if opponent:
		$SubViewport/Panel/Label.rotation_degrees = 180

	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
func update(title : String):
	$SubViewport/Panel/Label.text = title
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
