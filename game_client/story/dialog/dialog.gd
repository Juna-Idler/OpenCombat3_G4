extends Control

class_name DialogWindow

@export var character_per_second : float = 20.0


const Option := preload("res://game_client/story/dialog/option.tscn")

@onready var dialog_name : RubyLabel = %Name
@onready var dialog_text : RubyLabel = %Text

@onready var options_container = $CenterContainer/VBoxContainer

var is_aborted := false

var cut : DialogData.Cut :
	set(v):
		cut = v
		if cut.list[0].command == DialogData.CommandType.MESSAGE:
			var m := cut.list[0] as DialogData.CommandMessage
			dialog_name.text_input = m.name
			dialog_text.text_input = m.text
			dialog_text.display_rate = 0.0

var current_index : int = 0

enum Mode {
	ABORT,
	DIALOG,
	CHOICE,
}

var mode : Mode




# Called when the node enters the cut tree for the first time.
func _ready():
	var text_resource := load("res://game_client/story/test.txt")
	var scenario = DialogData.ScenarioPackage.load_text(text_resource.text)

	cut = scenario.cut.values()[0]

	$HSlider.value = character_per_second
	$LineEdit.text = str(character_per_second)

	mode = Mode.DIALOG
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dialog_text.display_rate < 100.0:
		var d := (character_per_second / (dialog_text.output_phonetic_text.length() + 0.01))
		dialog_text.display_rate += d * delta * 100.0
	pass


signal scenario_finished

func abort():
	mode = Mode.ABORT
	scenario_finished.emit()

func play_cut_async(c : DialogData.Cut) -> bool:
	cut = c
	await scenario_finished
	return mode == Mode.DIALOG
	

func show_options_async(option_names : PackedStringArray) -> int:
	mode = Mode.CHOICE
	var signals : Array[Signal] = []
	for i in option_names.size():
		var o := Option.instantiate()
		o.text = option_names[i]
		signals.append(o.pressed)
		options_container.add_child(o)
	signals.append(scenario_finished)
	var choice := await SignalWaiter.wait_any(signals)
	for o in options_container.get_children():
		options_container.remove_child(o)
		o.queue_free()
	
	if mode == Mode.ABORT:# choice == signals.size():
		return -1
	mode = Mode.DIALOG
	return choice


func dialog_next():
	if mode == Mode.DIALOG:
		if dialog_text.display_rate < 100:
			dialog_text.display_rate = 100
			return
		
		while true:
			current_index += 1
			if current_index >= cut.list.size():
				scenario_finished.emit()
				return
			if cut.list[current_index].command == DialogData.CommandType.MESSAGE:
				break
		dialog_name.text_input = cut.list[current_index].name
		dialog_text.text_input = cut.list[current_index].text
		dialog_text.display_rate = 0.0


func _on_test_button_pressed():
	dialog_next()


func _on_h_slider_value_changed(value):
	character_per_second = value
	$LineEdit.text = str(value)
	pass # Replace with function body.



var _pressed := false

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
