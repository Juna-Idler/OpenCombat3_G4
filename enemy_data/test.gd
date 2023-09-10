extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var d := EnemyDataFactory.create("dummy")
	var s = d.name
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
