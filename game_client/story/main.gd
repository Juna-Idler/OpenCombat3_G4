extends SceneChanger.IScene

var _scene_changer : SceneChanger


var story_data

@onready var dialog : DialogWindow = $Dialog
@onready var battle = $Battle


class Controller extends I_StoryController:
	var dialog : DialogWindow
	var battle : StoryBattle
	
	func _init(d : DialogWindow,b : StoryBattle):
		dialog = d
		battle = b
	
	func _play_cut_async(cut : DialogData.Cut) -> bool:
		dialog.show()
		await dialog.play_cut_async(cut)
		return false

	func _show_options_async(option_names : PackedStringArray) -> int:
		return await dialog.show_options_async(option_names)

	func _battle_start_async(deck : PackedInt32Array,enemy_name : String) -> int:
		dialog.hide()
		battle.initialize(deck,enemy_name)
		await battle.battle_finished
		battle.terminalize()
		return battle.battle_result
	
	func _fade_in_dialog_async(duration : float):
		var tween := dialog.create_tween()
		dialog.show()
		dialog.modulate.a = 0.0
		tween.tween_property(dialog,"modulate:a",1.0,duration)
		await tween.finished
	func _fade_out_dialog_async(duration : float):
		var tween := dialog.create_tween()
		tween.tween_property(dialog,"modulate:a",0.0,duration)
		await tween.finished
		dialog.hide()
		dialog.clear()
		
	func _fade_in_battle(_duration : float):
		pass
	func _fade_out_battle(_duration : float):
		pass

class TestScript extends I_StoryScript:
	var scenario : DialogData.ScenarioPackage
	
	func _init(scenario_text : String):
		scenario = DialogData.ScenarioPackage.load_text(scenario_text)
	
	func _start(controller : I_StoryController):
		var c_result := await controller._play_cut_async(scenario.cut.get("Start"))
		var o = scenario.options.get("選択肢")
		var option := await controller._show_options_async(o.name)
		var deck : PackedInt32Array
		if option == 0:
			deck = [7,8,9,7,8,9,7,8,9,7,8,9,7,8,9]
		else:
			deck = [1,2,3]
		await controller._fade_out_dialog_async(1.0)
		var b_result := await controller._battle_start_async(deck,"dummy")
		await controller._fade_in_dialog_async(1.0)
		if b_result > 0:
			await controller._play_cut_async(scenario.cut.get("Win"))
		elif b_result == 0:
			await controller._play_cut_async(scenario.cut.get("Lose"))
		await controller._play_cut_async(scenario.cut.get("End"))
		await controller._fade_out_dialog_async(1.0)




func _ready():
	_initialize(null,[])

func _process(_delta):
	pass

func _initialize(changer : SceneChanger,param : Array):
	_scene_changer = changer
	
#	var script : I_StoryScript = param[0]
#	await script._start()
	
#	story_data = _param[0]
#	story_data.start(dialog)
	var my_deck : PackedInt32Array = [1,2,3,7,8,9,7,8,9,7,8,9,7,8,9]

	
	var text_resource := load("res://game_client/story/test.txt")
	
	var script := TestScript.new(text_resource.text)
	
	await script._start(Controller.new(dialog,battle))
	
#	var scenario := DialogData.ScenarioPackage.load_text(text_resource.text)
#	await dialog.play_cut_async(scenario.get_first_cut())
#
#	var c := await dialog.show_options_async(["選択肢1","洗濯し2"])

	pass
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass


