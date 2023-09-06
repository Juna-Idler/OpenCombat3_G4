extends MeshInstance3D

class_name CardAura

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_aura_color() -> Color :
	var material := material_override as ShaderMaterial
	return material.get_shader_parameter("color")

func set_aura_color(color : Color):
	var material := material_override as ShaderMaterial
	material.set_shader_parameter("color",color)


func get_aura_intensity() -> float:
	var material := material_override as ShaderMaterial
	return material.get_shader_parameter("intensity")

func set_aura_intensity(i : float):
	var material := material_override as ShaderMaterial
	material.set_shader_parameter("intensity",i)
	
