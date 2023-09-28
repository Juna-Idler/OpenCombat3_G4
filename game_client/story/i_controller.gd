
class_name I_StoryController


func _dialog_clear() -> void:
	return

func _play_cut_async(_cut : DialogData.Cut) -> bool:
	@warning_ignore("redundant_await")
	return await false


func _show_options_async(_option_names : PackedStringArray) -> int:
	@warning_ignore("redundant_await")
	return await -1

func _fade_in_dialog_async(_duration : float):
	@warning_ignore("redundant_await")
	await null
func _fade_out_dialog_async(_duration : float):
	@warning_ignore("redundant_await")
	await null


func _battle_start_async(_player_name : String,_player_deck : PackedInt32Array,
		_player_hand : int,_shuffle : bool,
		_enemy_name : String,_battle_script : I_BattleScript) -> int:
	@warning_ignore("redundant_await")
	return await -1

func _tutorial_battle_start_async(player_name : String,
		player_deck : PackedInt32Array,player_hand : int,
		enemy_data : EnemyData,battle_script : I_BattleScript) -> int:
	@warning_ignore("redundant_await")
	return await -1

func _fade_in_battle(_duration : float):
	@warning_ignore("redundant_await")
	await null
func _fade_out_battle(_duration : float):
	@warning_ignore("redundant_await")
	await null


