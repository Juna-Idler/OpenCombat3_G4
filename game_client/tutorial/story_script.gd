
extends I_StoryScript


#var scenario : DialogData.ScenarioPackage
var battle_script : I_BattleScript

func _init(b_script : I_BattleScript):
	battle_script = b_script

func _start(controller : I_StoryController) -> bool:
	
	var cut := DialogData.Cut.create(
""" チュートリアル
	チュートリアル1を始めます。""")
	
	controller._dialog_clear()
	await controller._fade_in_dialog_async(1.0)
	var c_result := await controller._play_cut_async(cut)
	await controller._fade_out_dialog_async(1.0)
	var b_result := await controller._battle_start_async(Global.game_settings.player_name,
			[],1,"tutorial",battle_script)

	cut = DialogData.Cut.create(
""" チュートリアル
	チュートリアル1終了です。""")
	controller._dialog_clear()
	await controller._fade_in_dialog_async(1.0)
	await controller._play_cut_async(cut)
	await controller._fade_out_dialog_async(1.0)
	return true

