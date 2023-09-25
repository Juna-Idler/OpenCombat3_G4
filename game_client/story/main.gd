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
		return await dialog.play_cut_async(cut)

	func _show_options_async(option_names : PackedStringArray) -> int:
		return await dialog.show_options_async(option_names)

	func _battle_start_async(deck : PackedInt32Array,enemy_name : String,battle_script : I_BattleScript) -> int:
		dialog.hide()
		battle.initialize(deck,enemy_name,battle_script)
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
	
	func _start(controller : I_StoryController) -> bool:
		var c_result := await controller._play_cut_async(scenario.cut.get("Start"))
		if not c_result:
			return false
		var o = scenario.options.get("選択肢")
		var option := await controller._show_options_async(o.name)
		if option < 0:
			return false
		var deck : PackedInt32Array
		if option == 0:
			deck = [7,8,9,7,8,9,7,8,9,7,8,9,7,8,9]
		else:
			deck = [1,2,3]
		await controller._fade_out_dialog_async(1.0)
		var battle_resource = load("res://story_data/tutorial/1.txt")
		var b_result := await controller._battle_start_async(deck,"dummy",TestBattleScript.new(controller,battle_resource.text))
		await controller._fade_in_dialog_async(1.0)
		if b_result > 0:
			c_result = await controller._play_cut_async(scenario.cut.get("Win"))
		elif b_result == 0:
			c_result = await controller._play_cut_async(scenario.cut.get("Lose"))
		if not c_result:
			return false
		c_result = await controller._play_cut_async(scenario.cut.get("End"))
		if not c_result:
			return false
		await controller._fade_out_dialog_async(1.0)
		return true

class TestBattleScript extends I_BattleScript:
	var controller : I_StoryController
	var scenario : DialogData.ScenarioPackage
	
	
	func _init(c : I_StoryController,scenario_text : String):
		scenario = DialogData.ScenarioPackage.load_text(scenario_text)
		controller = c
	
	func _start_event() -> void:
		await controller._fade_in_dialog_async(0.5)
		await controller._play_cut_async(scenario.cut["Start"])
		await controller._fade_out_dialog_async(0.5)
		return
		
	func _hand_selected_event(_data : Data) -> bool:
		@warning_ignore("redundant_await")
		return await true
		
	func _performed_event(data : Data) -> bool:
		if data.phase == IGameServer.Phase.COMBAT:
			match data.round_count:
				1:
					await controller._fade_in_dialog_async(0.5)
					await controller._play_cut_async(scenario.cut["PlayCard"])
					await controller._fade_out_dialog_async(0.5)
				2:
					await controller._fade_in_dialog_async(0.5)
					await controller._play_cut_async(scenario.cut["Combat"])
					await controller._fade_out_dialog_async(0.5)
		return true
		
	func _end_event() -> void:
		return



func _ready():
	_initialize(null,[])

func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
#	var script : I_StoryScript = param[0]
#	await script._start()
	
#	story_data = _param[0]
#	story_data.start(dialog)
#	var my_deck : PackedInt32Array = [1,2,3,7,8,9,7,8,9,7,8,9,7,8,9]
#
#
	var text_resource := load("res://game_client/story/test.txt")
	var script := TestScript.new(text_resource.text)
	
	var _result := await script._start(Controller.new(dialog,battle))
	
#	var scenario := DialogData.ScenarioPackage.load_text(text_resource.text)
#	await dialog.play_cut_async(scenario.get_first_cut())
#
#	var c := await dialog.show_options_async(["選択肢1","洗濯し2"])

	pass
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass


