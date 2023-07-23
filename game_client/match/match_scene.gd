extends Node

var deck : Array[Card3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	const Card3D_Scene := preload("res://game_client/match/card3d.tscn")
	
	for i in 30:
		var c := Card3D_Scene.instantiate()
		deck.append(c)
		c.position.x = 3.5
		c.position.y = -1
		c.position.z = i * 0.01
		c.rotate_y(PI)
		$Field/CardHolder.add_child(c)
	var hand := deck.slice(0,4,1)
	$Field/HandArea.set_cards(hand)
	$Field/HandArea.move_card(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
