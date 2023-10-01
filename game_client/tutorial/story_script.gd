
extends I_StoryScript


#var scenario : DialogData.ScenarioPackage
var battle_script : I_BattleScript

var enemy_data : EnemyData
var player_deck : PackedInt32Array = [1]
var player_hand : int = 1

func _init(b_script : I_BattleScript):
	battle_script = b_script
	enemy_data = EnemyDataFactory.create("tutorial")
	

func _start(controller : I_StoryController) -> bool:
	
	controller._dialog_clear()
	var b_result := await controller._tutorial_battle_start_async(Global.game_settings.player_name,
			player_deck,player_hand,enemy_data,battle_script)

	return true

