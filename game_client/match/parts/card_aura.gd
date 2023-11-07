extends MeshInstance3D

class_name CardAura

var material : ShaderMaterial

func _ready():
	material = material_override.duplicate()
	material_override = material

func get_aura_color() -> Color :
	return material.get_shader_parameter("color")

func set_aura_color(color : Color):
	material.set_shader_parameter("color",color)


func get_aura_intensity() -> float:
	return material.get_shader_parameter("intensity")

func set_aura_intensity(i : float):
	material.set_shader_parameter("intensity",i)
	
