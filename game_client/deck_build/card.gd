extends "res://utility_code/draggable_control.gd"

var card_data : CatalogData.CardData

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.texture = $SubViewport.get_texture()
	pass # Replace with function body.


func initialize(cd : CatalogData.CardData):
	card_data = cd
	$SubViewport/CardFront.initialize(cd.name,cd.color,cd.level,
			cd.power,cd.hit,cd.block,cd.skills,load(cd.image))
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func get_card_data() -> CatalogData.CardData:
	return card_data

func get_texture() -> Texture2D:
	return $TextureRect.texture
