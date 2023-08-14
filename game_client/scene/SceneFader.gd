extends ISceneFader

@export var ex : Texture2D

var fader : InnerTransitionFader

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


class InnerTransitionFader extends ISceneFader:
	var tween : Tween
#	var material : ShaderMaterial
	
	var rule : Texture2D:
		set(v):
			rule = v
			if material:
				var sm := material as ShaderMaterial
				sm.set_shader_param("rule",v)

	var invert : bool:
		set(v):
			invert = v
			if material:
				var sm := material as ShaderMaterial
				sm.set_shader_param("invert",v)
	

	func initialize(r : Texture2D,inv : bool):
		var sm = ShaderMaterial.new()
		sm.shader = preload("transition_fade.gdshader")
		sm.set_shader_param("rule", r)
		sm.set_shader_param("invert",inv)
		set_rate(0.0)
		material = sm
		pass

	func set_rate(r):
		material.set_shader_param("rate",r)

	func _fade_out(duration : float):
		if material:
			tween = create_tween()
			tween.tween_method(set_rate,0.0,1.0,duration)
			await tween.finished

	func _fade_in(duration : float):
		if material:
			tween = create_tween()
			tween.tween_method(set_rate,1.0,0.0,duration)
			await tween.finished

	func _stop_fade(rate : float):
		if tween and tween.is_running():
			tween.kill()
			set_rate(rate)

