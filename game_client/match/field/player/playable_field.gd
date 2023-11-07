extends BasePlayerField

class_name PlayablePlayerField


signal hand_selected(index : int,hand : Array[Card3D])


func _ready():
	super()
	hand_area = $HandArea
	pass # Replace with function body.


func _on_hand_area_selected(index, hand):
	hand_selected.emit(index,hand)
	pass # Replace with function body.


func _on_hand_area_drag_start(card : Card3D):
	_put_on_aura(card,get_selecting_aura_color(card))
	pass # Replace with function body.


func _on_hand_area_drag_cancel(card : Card3D):
	_take_off_aura(card)
	pass # Replace with function body.


func _on_hand_area_entered_play_zone(_card : Card3D):
	match _match_scene.phase:
		IGameServer.Phase.COMBAT:
			_card_aura.set_aura_color(Color.WHITE)
		IGameServer.Phase.RECOVERY:
			_card_aura.set_aura_color(Color.BLACK)

func _on_hand_area_exited_play_zone(card : Card3D):
	_card_aura.set_aura_color(get_selecting_aura_color(card))


func get_selecting_aura_color(card : Card3D) -> Color:
	match _match_scene.phase:
		IGameServer.Phase.COMBAT:
			return CatalogData.RGB[card.color]
		IGameServer.Phase.RECOVERY:
			return CatalogData.RGB[card.color].inverted()
	return Color.TRANSPARENT

