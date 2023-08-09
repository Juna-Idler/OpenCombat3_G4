extends Node3D

@export_multiline var text : String = "":
	set(v):
		if text != v:
			text = v
			$SubViewport/Label.text = text
			$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	get:
		return text

@export var label_settings : LabelSettings:
	set(v):
		$SubViewport/Label.label_settings = v
	get:
		return $SubViewport/Label.label_settings
	
@export var viewport_size : Vector2i:
	set(v):
		$SubViewport.size = v
	get:
		return $SubViewport.size

@export var board_size : Vector2:
	set(v):
		var mesh := $".".mesh as QuadMesh
		mesh.size = v
	get:
		var mesh := $".".mesh as QuadMesh
		return mesh.size


# Called when the node enters the scene tree for the first time.
func _ready():
	var material := $".".material_override as StandardMaterial3D
	material.albedo_texture = $SubViewport.get_texture()	
	pass # Replace with function body.


