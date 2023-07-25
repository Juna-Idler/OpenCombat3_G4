
class_name I_MatchPlayer

func _get_scene() -> Node3D:
	return null

func _initialize(_player_name:String,_deck : PackedInt32Array,_catalog : CardCatalog) -> void:
	pass

func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass


func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	return

func _perform_effect(_effect : IGameServer.EffectLog,_rival : I_MatchPlayer) -> void:
	pass

func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	pass

func _get_playing_card() -> Card3D:
	return null

func _combat_end() -> void:
	return



