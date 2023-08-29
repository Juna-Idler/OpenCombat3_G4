extends Panel


@onready var mover = %Mover


var dragging := false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

var scroll : float = 0

func _process(_delta):
	var pos := get_global_mouse_position()
	var scroll_point : Vector2 = %ScrollContainer.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%ScrollContainer.size).has_point(scroll_point):
		if scroll_point.x < 128:
			scroll = -300
		elif scroll_point.x > %ScrollContainer.size.x - 128:
			scroll = 300
		else:
			scroll = 0
		%ScrollContainer.scroll_horizontal += scroll * _delta

		if dragging:
			var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
			if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
				%DeckSequence.pointing(point)
		
	pass


func _on_color_rect_clicked(_self):
	print("clicked")
	pass # Replace with function body.


func _on_color_rect_held(_self):
	print("held")
	pass # Replace with function body.

func _on_color_rect_drag_start(_self, _pos):
	dragging = true
	print("drag_start")
	mover.show()
	mover.global_position = get_global_mouse_position() - mover.size / 2
	pass # Replace with function body.

func _on_color_rect_dragging(_self, _relative_pos, _start_pos):
	print("dragging")
#	var pos : Vector2 = _self.global_position + _start_pos + _relative_pos
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = $VBoxContainer/ScrollContainer/DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,$VBoxContainer/ScrollContainer/DeckSequence.size).has_point(point):
		$VBoxContainer/ScrollContainer/DeckSequence.pointing(point)
	else:
		%DeckSequence.exit()

	mover.global_position = pos - mover.size / 2
	

func _on_color_rect_dropped(_self, _relative_pos, _start_pos):
	dragging = false
	print("dropped")
#	var pos : Vector2 = _self.global_position + _start_pos + _relative_pos
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = $VBoxContainer/ScrollContainer/DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,$VBoxContainer/ScrollContainer/DeckSequence.size).has_point(point):
		%DeckSequence.drop(point)
	else:
		%DeckSequence.exit()
	scroll = 0
	mover.hide()


func _on_color_rect_double_clicked(_self):
	print("double clicked")
	pass # Replace with function body.
