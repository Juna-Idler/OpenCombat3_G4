extends Node3D

class_name I_PlayerField


signal hand_clicked(card : Card3D)

enum EffectTiming {INITIAL,START,BEFORE,MOMENT,AFTER,END}



func _get_catalog() -> I_CardCatalog:
	return null

func _initialize(_player_name:String,_deck : PackedInt32Array,
		_catalog : I_CardCatalog,_opponent : bool,
		_cpbi : CombatPowerBalance.Interface,
		_log_display : LogDisplay) -> void:
	pass
func _set_rival(_rival : I_PlayerField) -> void:
	pass


func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass

func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	pass

func _get_playing_card() -> Card3D:
	return null

func _get_enchant_data(_id : int) -> CatalogData.StateData:
	return null

func _get_enchant_title(_id : int,_param) -> String:
	return ""

func _combat_end() -> void:
	pass


func _perform_effect(_effect : IGameServer.EffectLog) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	
func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _perform_passive(_passive : IGameServer.PassiveLog,_duration : float) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _perform_simultaneous_initiative(_fragment : IGameServer.EffectFragment,_duration : float) -> void:
	pass
	
func _perform_simultaneous_supply(_effect : IGameServer.EffectLog,_duration : float) -> float:
	return 0


func _perform_attack(_unblocked_damage : int,_blocked_damage : int) -> void:
	pass
func _damaged(_unblocked_damage : int,_blocked_damage : int) -> void:
	pass


func _begin_timing(_timing : EffectTiming) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _finish_timing(_timing : EffectTiming) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
