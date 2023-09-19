
class_name I_StoryController


func _play_cut_async(_cut : DialogData.Cut) -> bool:
	@warning_ignore("redundant_await")
	return await false


func _show_options_async(_option_names : PackedStringArray) -> int:
	@warning_ignore("redundant_await")
	return await -1



func _battle_start_async(_deck : PackedInt32Array,_enemy_name : String) -> int:
	@warning_ignore("redundant_await")
	return await -1
	
	
