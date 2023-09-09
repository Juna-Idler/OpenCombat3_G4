extends Node3D

class_name I_PlayerField


enum EffectTiming {INITIAL,START,BEFORE,MOMENT,AFTER,END}


signal request_card_list_view(p_cards : Array[Card3D],d_cards : Array[Card3D])

signal request_enchant_list_view(enchantments : Dictionary)


func _get_catalog() -> I_CardCatalog:
	return null

func _initialize(_match_scene : MatchScene,
		_player_name:String,_deck : PackedInt32Array,
		_catalog : I_CardCatalog,_opponent : bool,
		_on_card_clicked : Callable,
		_log_display : LogDisplay) -> void:
	pass

func _terminalize():
	pass

func _set_rival(_rival : I_PlayerField) -> void:
	pass


func _set_first_data(_data : IGameServer.FirstData.PlayerData) -> void:
	pass

func _combat_start(_hand : PackedInt32Array,_select : int) -> void:
	pass

func _get_playing_card() -> Card3D:
	return null


class Enchant:
	var id : int
	var data : CatalogData.EnchantmentData
	var param : Array
	var from_opponent : bool

func _get_enchant_dictionary() -> Dictionary:	# key = id, value = Enchant
	return {}
	
func _combat_end() -> void:
	pass
	
func _recovery_start(_hand : PackedInt32Array,_select : int) -> void:
	pass
func _recovery_end(_life : int):
	pass


func _perform_ability(_ability : IGameServer.AbilityLog) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _perform_effect(_effect : IGameServer.EffectLog) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	
func _perform_effect_fragment(_fragment : IGameServer.EffectFragment) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0

func _passive_sequence(_passive : IGameServer.PassiveLog) -> void:
	pass

func _passive_coroutine(_passive : IGameServer.PassiveLog,_duration : float) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	

func _perform_simultaneous_initiative(_fragment : IGameServer.EffectFragment,_duration : float) -> void:
	pass
	
func _perform_simultaneous_supply(_effect : IGameServer.EffectLog,_duration : float) -> float:
	return 0


func _perform_attack(_unblocked_damage : int,_blocked_damage : int) -> void:
	assert(false)
	@warning_ignore("redundant_await")
	await 0
	
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


func _set_complete_board(_data : IGameServer.CompleteData.PlayerData):
	pass
	
