extends I_BattleScript

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
	return true
	
func _performed_event(data : Data) -> bool:
	if data.phase == IGameServer.Phase.COMBAT:
		match data.round_count:
			1:
				await controller._fade_in_dialog_async(0.5)
				await controller._play_cut_async(scenario.cut["Round1"])
				await controller._fade_out_dialog_async(0.5)
			2:
				await controller._fade_in_dialog_async(0.5)
				await controller._play_cut_async(scenario.cut["Round2"])
				await controller._fade_out_dialog_async(0.5)
			3:
				await controller._fade_in_dialog_async(0.5)
				await controller._play_cut_async(scenario.cut["Round3"])
				await controller._fade_out_dialog_async(0.5)
			4:
				await controller._fade_in_dialog_async(0.5)
				await controller._play_cut_async(scenario.cut["Round4"])
				await controller._fade_out_dialog_async(0.5)
			5:
				await controller._fade_in_dialog_async(0.5)
				await controller._play_cut_async(scenario.cut["Round5"])
				await controller._fade_out_dialog_async(0.5)
			
	return true
	
func _end_event() -> void:
	await controller._fade_in_dialog_async(0.5)
	await controller._play_cut_async(scenario.cut["End"])
	await controller._fade_out_dialog_async(0.5)
	return
