@tool

extends ISceneFader

class_name TransitionFader


@export_range(0.0,1.0) var rate : float:
	set(v):
		rate = v
		if material and material is ShaderMaterial:
			set_rate(v)

@export var rule : Texture2D:
	set(v):
		rule = v
		if material and material is ShaderMaterial:
			var sm := material as ShaderMaterial
			sm.set_shader_parameter("rule",v)

@export var invert : bool:
	set(v):
		invert = v
		if material and material is ShaderMaterial:
			var sm := material as ShaderMaterial
			sm.set_shader_parameter("invert",v)

var tween : Tween

func _ready():
	var sm = ShaderMaterial.new()
	sm.shader = preload("transition_fade.gdshader")
	sm.set_shader_parameter("rule", rule)
	sm.set_shader_parameter("invert",invert)
	material = sm
	pass

func set_rate(r):
	material.set_shader_parameter("rate",r)

func _fade_out(duration : float):
	if material and material is ShaderMaterial:
		tween = create_tween()
		tween.tween_method(set_rate,0.0,1.0,duration)
		await tween.finished

func _fade_in(duration : float):
	if material and material is ShaderMaterial:
		tween = create_tween()
		tween.tween_method(set_rate,1.0,0.0,duration)
		await tween.finished

func _stop_fade(rate : float):
	if tween and tween.is_running():
		tween.kill()
		set_rate(rate)

