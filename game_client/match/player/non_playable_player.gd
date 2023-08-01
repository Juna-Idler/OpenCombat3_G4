extends I_MatchPlayer

class_name NonPlayablePlayer

const Field := preload("res://game_client/match/player/field/player_field.tscn")
const NonPlayableHandArea := preload("res://game_client/match/player/field/hand_area.tscn")

var _field
var _hand_area : HandArea
var _catalog : CardCatalog
var _rival : I_MatchPlayer

func _init():
	_field = Field.instantiate()
	

func _get_field() -> Node3D:
	return _field

func _get_catalog() -> I_CardCatalog:
	return _catalog

func _initialize(player_name:String,deck : PackedInt32Array,
		catalog : I_CardCatalog,opponent : bool,
		cpbi : CombatPowerBalance.Interface) -> void:
	_hand_area = NonPlayableHandArea.instantiate()
	_field.initialize(_hand_area,player_name,deck,catalog,opponent,cpbi)
	_hand_area.clicked.connect(func(c):hand_clicked.emit(c))
	_catalog = catalog
	
func _set_rival(rival : I_MatchPlayer) -> void:
	_rival = rival
	_field.set_rival_catalog(_rival._get_catalog())

func _set_first_data(data : IGameServer.FirstData.PlayerData) -> void:
	_field.set_first_data(data)


func _combat_start(hand : PackedInt32Array,select : int) -> void:
	await _field.combat_start(hand,select)

func _perform_effect(effect : IGameServer.EffectLog) -> void:
	await _field.perform_effect(effect)
	for f in effect.fragment:
		if f.opponent:
			await _rival._perform_effect_fragment(f)
		else:
			await _perform_effect_fragment(f)


func _perform_effect_fragment(fragment : IGameServer.EffectFragment) -> void:
	await _field.perform_effect_fragment(fragment)
	for p in fragment.passive:
		if p.opponent:
			await _rival._perform_passive(p)
		else:
			await _perform_passive(p)

func _perform_passive(passive : IGameServer.PassiveLog) -> void:
	await _field.perform_passive(passive)


func _get_playing_card() -> Card3D:
	return _field.get_playing_card()

func _combat_end() -> void:
	await _field.combat_end()

func _begin_timing(timing : EffectTiming) -> void:
	await _field.begin_timing(timing)

func _finish_timing(timing : EffectTiming) -> void:
	await _field.finish_timing(timing)


func fix_select_card(card : Card3D):
	await _field.fix_select_card(card)

