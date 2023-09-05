extends Control

@export var duration_per_character : float = 0.1


@onready var dialog_name : RubyLabel = %Name
@onready var dialog_text : RubyLabel = %Text



var scenario : DialogData.SequencialScenario


# Called when the node enters the scene tree for the first time.
func _ready():
	$HSlider.value = duration_per_character
	$LineEdit.text = str(duration_per_character)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dialog_text.display_rate < 100.0:
		var d := ((1.0 / duration_per_character) / (dialog_text.output_phonetic_text.length() + 0.01))
		dialog_text.display_rate += d * delta * 100.0
	pass


func _on_test_button_pressed():
	dialog_text.display_rate = 0.0
	pass # Replace with function body.


func _on_h_slider_value_changed(value):
	duration_per_character = value
	$LineEdit.text = str(value)
	pass # Replace with function body.
