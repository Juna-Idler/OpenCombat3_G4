extends I_MatchPlayer

class_name NonPlayablePlayer

const Field := preload("res://game_client/match/player/field/player_field.tscn")
const NonPlayableHandArea := preload("res://game_client/match/player/field/hand_area.tscn")

var _field
var _hand_area : HandArea

func _init():
	_field = Field.instantiate()
	

func _get_field() -> Node3D:
	return _field

func _initialize(player_name:String,deck : PackedInt32Array,catalog : CardCatalog,opponent : bool) -> void:
	_hand_area = NonPlayableHandArea.instantiate()
	_field.initialize(_hand_area,player_name,deck,catalog,opponent)
	_hand_area.clicked.connect(func(c):hand_clicked.emit(c))

func _set_first_data(data : IGameServer.FirstData.PlayerData) -> void:
	_field.set_first_data(data)


func _combat_start(hand : PackedInt32Array,select : int) -> void:
	await _field.combat_start(hand,select)

func _perform_effect(effect : IGameServer.EffectLog,rival : I_MatchPlayer) -> void:
	await _field.perform_effect(effect)
	for f in effect.fragment:
		if f.opponent:
			await rival._perform_effect_fragment(f,self)
		else:
			await _perform_effect_fragment(f,rival)


func _perform_effect_fragment(fragment : IGameServer.EffectFragment,rival : I_MatchPlayer) -> void:
	await _field.perform_effect_fragment(fragment)
	for p in fragment.passive:
		if p.opponent:
			await rival._perform_passive(p)
		else:
			await _perform_passive(p)

func _perform_passive(passive : IGameServer.PassiveLog) -> void:
	await _field.perform_passive(passive)


func _get_playing_card() -> Card3D:
	return null

func _combat_end() -> void:
	await _field.combat_end()


func fix_select_card(card : Card3D):
	await _field.fix_select_card(card)

