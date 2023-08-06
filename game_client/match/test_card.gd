extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
#	var tween := create_tween()
#	tween.tween_method($Node3D.set_transparency,1.0,0.0,3)
#	tween.tween_method($Node3D.set_transparency,0.0,1.0,3)
#	tween.set_loops(10)
#	pass # Replace with function body.


	var cd :=  Global.card_catalog._get_card_data(4)
	var pict = load(cd.image)
	$Control.initialize(cd,cd.color,cd.level,cd.power,cd.hit,cd.block,cd.skills,pict)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
