extends Control

@export var duration_per_character : float = 0.1


@onready var dialog_name : RubyLabel = %Name
@onready var dialog_text : RubyLabel = %Text



var scenario : DialogData.SequencialScenario
var current_index : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	var text_resource := load("res://game_client/story/test.txt")
	scenario = DialogData.SequencialScenario.load_text(text_resource.text)
	if not scenario.list.is_empty():
		dialog_name.text_input = scenario.list[0].name
		dialog_text.text_input = scenario.list[0].text
	dialog_text.display_rate = 0.0
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
	if dialog_text.display_rate < 100:
		dialog_text.display_rate = 100
		return
	current_index += 1
	if current_index >= scenario.list.size():
		current_index = 0
	dialog_name.text_input = scenario.list[current_index].name
	dialog_text.text_input = scenario.list[current_index].text
	dialog_text.display_rate = 0.0
	pass # Replace with function body.


func _on_h_slider_value_changed(value):
	duration_per_character = value
	$LineEdit.text = str(value)
	pass # Replace with function body.
