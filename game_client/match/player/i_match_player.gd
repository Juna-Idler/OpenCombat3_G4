
class_name I_MatchPlayer

signal hand_clicked(card : Card3D)

enum EffectTiming {INITIAL,START,BEFORE,MOMENT,AFTER,END}


func _get_field() -> Node3D:
	return null

func _get_catalog() -> I_CardCatalog:
	return null

func _initialize(_player_name:String,_deck : PackedInt32Array,_catalog : I_CardCatalog,_opponent : bool) -> void:
	pass
func _set_rival(_rival : I_MatchPlayer) -> void:
	pass


func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass


func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	pass

func _perform_effect(_effect : IGameServer.EffectLog) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	
func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _perform_passive(_passive : IGameServer.PassiveLog) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _get_playing_card() -> Card3D:
	return null
	

func _combat_end() -> void:
	pass


func _begin_timing(_timing : EffectTiming) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _finish_timing(_timing : EffectTiming) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
