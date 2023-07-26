
class_name I_MatchPlayer

signal sync_action_finished
#_combat_start(),_perform_effect_sync(),_combat_end()


func _get_scene() -> Node3D:
	return null

func _initialize(_player_name:String,_deck : PackedInt32Array,_catalog : CardCatalog,_opponent : bool) -> void:
	pass

func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass


func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	sync_action_finished.emit()
	pass

func _perform_effect(_effect : IGameServer.EffectLog,_rival : I_MatchPlayer) -> void:
	@warning_ignore("redundant_await")
	await 0

func _perform_effect_sync(_effect : IGameServer.EffectLog,_rival : I_MatchPlayer) -> void:
	sync_action_finished.emit()
	pass
	
func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	@warning_ignore("redundant_await")
	await 0

func _get_playing_card() -> Card3D:
	return null

func _combat_end() -> void:
	sync_action_finished.emit()
	pass



