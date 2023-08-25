extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initialize(opponent : bool):
	if opponent:
		$Power/Label.rotation_degrees = 180
		$Hit/Label.rotation_degrees = 180
		$Block/Label.rotation_degrees = 180
	else:
		$Power/Label.rotation_degrees = 0
		$Hit/Label.rotation_degrees = 0
		$Block/Label.rotation_degrees = 0

var _color : Color
func set_color(color : Color):
	_color = color
	$Power/Power.color = color.darkened(0.2)
	$Hit/Hit.color = color.darkened(0.4)
	$Block/Block.color = color.darkened(0.4)

func set_initiative(i : bool):
	if i:
		$Power/Power.color = _color.darkened(0.2)
	else:
		$Power/Power.color = Color.DARK_GRAY

func set_initiative_async(i : bool,duration : float):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var color := _color.darkened(0.2) if i else Color.DARK_GRAY
	tween.tween_property($Power/Power,"color",color,duration)
	await tween.finished

func set_stats(p : int,h : int,b : int):
	$Power/Label.text = str(p)
	$Hit/Label.text = str(h)
	$Block/Label.text = str(b)

