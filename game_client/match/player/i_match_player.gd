
class_name I_MatchPlayer

signal hand_clicked(card : Card3D)




func _get_field() -> Node3D:
	return null

func _initialize(_player_name:String,_deck : PackedInt32Array,_catalog : CardCatalog,_opponent : bool) -> void:
	pass

func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass


func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	pass

func _perform_effect(_effect : IGameServer.EffectLog,_rival : I_MatchPlayer) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	
func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _get_playing_card() -> Card3D:
	return null

func _combat_end() -> void:
	pass



