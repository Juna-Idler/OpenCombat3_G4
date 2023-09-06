extends ColorRect

const ListItem := preload("res://game_client/match/parts/enchant_list_item.tscn")

@onready var v_box_container = %VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(enchantments : Dictionary):
	for c in v_box_container.get_children():
		v_box_container.remove_child(c)
		c.queue_free()
	for k in enchantments:
		var e := enchantments[k] as I_PlayerField.Enchant
		var item = ListItem.instantiate()
		item.initialize(e.data,e.param)
		$ScrollContainer/VBoxContainer.add_child(item)
	pass
	


func _on_gui_input(event):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		hide()
