class_name SceneChanger

var _master_scene : MasterScene
var _fader : ISceneFader
var _current_scene : IScene

var fade_in_duration : float = 0.5
var fade_out_duration : float = 0.5

func _init(master : MasterScene,f : ISceneFader,c : IScene):
	_master_scene = master
	_fader = f
	_current_scene = c
	


func goto_scene(tscn_path : String,param : Array):
	_fader.show()
	await _fader._fade_out(fade_out_duration)
	if _current_scene != null:
		_current_scene._terminalize()
		_master_scene.remove_child(_current_scene)
		_current_scene.queue_free()
	_current_scene = load(tscn_path).instantiate()
	_master_scene.add_child(_current_scene)
	_master_scene.move_child(_current_scene,0)
	_current_scene._initialize(self,param)
	await _fader._fade_in(fade_in_duration)
	_fader.hide()
	_current_scene._fade_in_finished()


class IScene extends Node:
	func _initialize(_changer : SceneChanger,_param : Array):
		pass
	func _fade_in_finished():
		pass
	func _terminalize():
		pass
