extends "res://game_client/match/player/field/base_player_field.gd"

class_name PlayablePlayerField


const CardAura := preload("res://game_client/match/card_aura.tscn")


signal hand_selected(index : int,hand : Array[Card3D])



var card_aura : CardAura

var _aura_tween : Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	hand_area = $HandArea
	card_aura = CardAura.instantiate()
	
	_aura_tween = create_tween()
	_aura_tween.kill()
	
	pass # Replace with function body.


func _on_hand_area_selected(index, hand):
	hand_selected.emit(index,hand)
	take_off_aura(hand[index])
	pass # Replace with function body.


func _on_hand_area_drag_start(card : Card3D):
	put_on_aura(card)
	pass # Replace with function body.


func _on_hand_area_drag_cancel(card : Card3D):
	take_off_aura(card)
	pass # Replace with function body.


func _on_hand_area_entered_play_zone(_card : Card3D):
	match _match_scene.phase:
		IGameServer.Phase.COMBAT:
			card_aura.set_aura_color(Color.WHITE)
		IGameServer.Phase.RECOVERY:
			card_aura.set_aura_color(Color.BLACK)

func _on_hand_area_exited_play_zone(card : Card3D):
	set_selecting_aura_color(card)


func put_on_aura(card : Card3D):
	_aura_tween.kill()
	if card_aura.get_parent():
		card_aura.get_parent().remove_child(card_aura)
	card.add_child(card_aura)
	_aura_tween = create_tween()
	_aura_tween.tween_method(card_aura.set_aura_intensity,0.0,1.0,0.3)
	set_selecting_aura_color(card)

func take_off_aura(card : Card3D):
	_aura_tween.kill()
	_aura_tween = create_tween()
	_aura_tween.tween_method(card_aura.set_aura_intensity,1.0,0.0,0.3)
	_aura_tween.tween_callback(card.remove_child.bind(card_aura))

func set_selecting_aura_color(card):
	match _match_scene.phase:
		IGameServer.Phase.COMBAT:
			card_aura.set_aura_color(CatalogData.RGB[card.color])
		IGameServer.Phase.RECOVERY:
			card_aura.set_aura_color(CatalogData.RGB[card.color].inverted())

