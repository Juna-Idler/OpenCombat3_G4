extends NonPlayablePlayer

class_name PlayablePlayer


const PlayableHandArea := preload("res://game_client/match/player/field/playable_hand_area.tscn")


signal hand_selected(index : int,hand : Array[Card3D])
signal hand_entered_play_zone(card : Card3D)
signal hand_exited_play_zone(card : Card3D)


func _init():
	super._init()
	
func _initialize(player_name:String,deck : PackedInt32Array,
		catalog : I_CardCatalog,opponent : bool,
		cpbi : CombatPowerBalance.Interface) -> void:
	_hand_area = PlayableHandArea.instantiate()
	_field.initialize(_hand_area,player_name,deck,catalog,opponent,cpbi)
	_hand_area.clicked.connect(func(c):hand_clicked.emit(c))
	_hand_area.selected.connect(func(c,h):hand_selected.emit(c,h))
	_hand_area.entered_play_zone.connect(func(c):hand_entered_play_zone.emit(c))
	_hand_area.exited_play_zone.connect(func(c):hand_exited_play_zone.emit(c))
	_catalog = catalog


