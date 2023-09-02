extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(log_data : MatchLog,title : String):
	$LabelTitle.text = title
	$LabelPlayer1.text = log_data.primary_data.my_name
	$LabelPlayer2.text = log_data.primary_data.rival_name

	
