extends Control

class_name DialogWindow

@export var duration_per_character : float = 0.1


const Choice := preload("res://game_client/story/dialog/choice.tscn")

@onready var dialog_name : RubyLabel = %Name
@onready var dialog_text : RubyLabel = %Text

@onready var choices_container = $CenterContainer/VBoxContainer



var scenario : DialogData.SequencialScenario :
	set(v):
		scenario = v
		if not scenario.list.is_empty():
			dialog_name.text_input = scenario.list[0].name
			dialog_text.text_input = scenario.list[0].text
		dialog_text.display_rate = 0.0

var current_index : int = 0

enum Mode {
	DIALOG,
	CHOICE,
}

var mode : Mode


var _pressed := false


# Called when the node enters the scene tree for the first time.
func _ready():
	var text_resource := load("res://game_client/story/test.txt")
	scenario = DialogData.SequencialScenario.load_text(text_resource.text)

	$HSlider.value = duration_per_character
	$LineEdit.text = str(duration_per_character)

	mode = Mode.DIALOG

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dialog_text.display_rate < 100.0:
		var d := ((1.0 / duration_per_character) / (dialog_text.output_phonetic_text.length() + 0.01))
		dialog_text.display_rate += d * delta * 100.0
	pass


signal scenario_finished

func set_and_wait_scenario(s : DialogData.SequencialScenario):
	scenario = s
	await scenario_finished
	

func dialog_next():
	if mode == Mode.DIALOG:
		if dialog_text.display_rate < 100:
			dialog_text.display_rate = 100
			return
		current_index += 1
		if current_index >= scenario.list.size():
			scenario_finished.emit()
			return
		dialog_name.text_input = scenario.list[current_index].name
		dialog_text.text_input = scenario.list[current_index].text
		dialog_text.display_rate = 0.0



func show_choices(choices : PackedStringArray) -> int:
	assert(not choices.is_empty())
	mode = Mode.CHOICE
	var signals : Array[Signal] = []
	for i in choices.size():
		var c := Choice.instantiate()
		c.text = choices[i]
		signals.append(c.pressed)
		choices_container.add_child(c)
	var choice := await SignalWaiter.wait_any(signals)
	
	for c in choices_container.get_children():
		choices_container.remove_child(c)
		c.queue_free()
	
	mode = Mode.DIALOG

	return choice



func _on_test_button_pressed():
	dialog_next()


func _on_h_slider_value_changed(value):
	duration_per_character = value
	$LineEdit.text = str(value)
	pass # Replace with function body.



func _on_gui_input(event):
	if _pressed:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			_pressed = false
			var rect := Rect2(Vector2.ZERO,size)
			if rect.has_point((event as InputEventMouseButton).position):
				dialog_next()
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_pressed = true
	pass # Replace with function body.
