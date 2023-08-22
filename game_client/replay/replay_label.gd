extends Button

var log : MatchLog

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(log : MatchLog,title : String):
	$LabelTitle.text = title
	$LabelPlayer1.text = log.primary_data.my_name
	$LabelPlayer2.text = log.primary_data.rival_name

	
