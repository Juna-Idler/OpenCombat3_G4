extends "res://game_client/match/player/field/non_playable_field.gd"

class_name PlayablePlayerField

const PlayableHandArea := preload("res://game_client/match/player/field/hand_area/playable_hand_area.tscn")


signal hand_selected(index : int,hand : Array[Card3D])
signal hand_entered_play_zone(card : Card3D)
signal hand_exited_play_zone(card : Card3D)

# Called when the node enters the scene tree for the first time.
func _ready():
	hand_area = PlayableHandArea.instantiate()
	add_child(hand_area)
	hand_area.clicked.connect(func(c):hand_clicked.emit(c))
	hand_area.position.y = -1.5
	hand_area.position.z = 0.5
	hand_area.selected.connect(func(c,h):hand_selected.emit(c,h))
	hand_area.entered_play_zone.connect(func(c):hand_entered_play_zone.emit(c))
	hand_area.exited_play_zone.connect(func(c):hand_exited_play_zone.emit(c))
	pass # Replace with function body.


