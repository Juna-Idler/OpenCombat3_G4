extends I_MatchPlayer

class_name PlayablePlayer

const Field := preload("res://game_client/match/playable_player/playable_field.tscn")

var _scene

func _init():
	_scene = Field.instantiate()
	

func _get_scene() -> Node3D:
	return _scene

func _initialize(player_name:String,deck : PackedInt32Array,catalog : CardCatalog) -> void:
	_scene.initialize(player_name,deck,catalog)

func _set_first_data(data : IGameServer.FirstData.PlayerData) -> void:
	_scene.set_first_data(data)


func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	return

func perform_effect(_effect : IGameServer.EffectLog,_rival : I_MatchPlayer) -> void:
	pass

func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	pass

func _get_playing_card() -> Card3D:
	return null

func _combat_end() -> void:
	return



