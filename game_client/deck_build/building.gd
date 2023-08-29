extends Panel


@onready var mover = %Mover

var drag_card : Control = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var list := Global.card_catalog._get_card_id_list()
	
	for c in %DeckSequence.get_children():
		c.drag_start.connect(_on_card_drag_start)
		c.dragging.connect(_on_card_dragging)
		c.dropped.connect(_on_card_dropped)

	var i := 0
	for c in %GridContainer.get_children():
		c.drag_start.connect(_on_pool_card_drag_start)
		c.dragging.connect(_on_pool_card_dragging)
		c.dropped.connect(_on_pool_card_dropped)
		c.mouse_entered.connect(_on_pool_card_mouse_entered.bind(c))
		c.mouse_exited.connect(_on_pool_card_mouse_exited.bind(c))
		
		var cd := Global.card_catalog._get_card_data(list[i])
		c.initialize(cd)
		i += 1


func _process(_delta):
	var pos := get_global_mouse_position()
	var scroll_point : Vector2 = %ScrollContainer.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%ScrollContainer.size).has_point(scroll_point):
		var scroll := 0.0
		if scroll_point.x < 128:
			scroll = -300
		elif scroll_point.x > %ScrollContainer.size.x - 128:
			scroll = 300
		else:
			scroll = 0
		%ScrollContainer.scroll_horizontal += scroll * _delta

		if drag_card:
			var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
			if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
				%DeckSequence.pointing(point)
		


func _on_card_drag_start(_self, _pos):
	%DeckSequence.drag_start(_self)
	
	_self.modulate.a = 0.1
	
	mover.show()
	mover.modulate.a = 1.0
	mover.global_position = get_global_mouse_position() - mover.size / 2
	mover.texture = _self.get_texture()
	
	drag_card = _self


func _on_card_dragging(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		%DeckSequence.pointing(point)
		mover.modulate.a = 1.0
	else:
		%DeckSequence.exit()
		mover.modulate.a = 0.3

#	drag_card.global_position = pos - drag_card.size / 2
	mover.global_position = pos - mover.size / 2


func _on_card_dropped(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		drag_card.modulate.a = 1.0
		drag_card.global_position = pos - drag_card.size / 2
		%DeckSequence.drop(drag_card,point)
	else:
		%DeckSequence.remove_child(drag_card)
		drag_card.queue_free()
		%DeckSequence.exit()
	
	drag_card = null
	mover.hide()


func _on_pool_card_drag_start(_self, _pos):
	drag_card = _self
	drag_card.modulate.a = 0.5
	mover.show()
	mover.modulate.a = 1.0
	mover.global_position = get_global_mouse_position() - mover.size / 2
	
	mover.texture = _self.get_texture()


func _on_pool_card_dragging(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		%DeckSequence.pointing(point)
	else:
		%DeckSequence.exit()
	mover.global_position = pos - mover.size / 2


func _on_pool_card_dropped(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		const DeckCard := preload("res://game_client/deck_build/card.tscn")
		var c := DeckCard.instantiate()
		c.drag_start.connect(_on_card_drag_start)
		c.dragging.connect(_on_card_dragging)
		c.dropped.connect(_on_card_dropped)
		c.initialize(_self.get_card_data())
		%DeckSequence.drop(c,point)
	else:
		%DeckSequence.exit()
	mover.hide()
	drag_card.modulate.a = 1.0
	drag_card = null


func _on_pool_card_mouse_entered(card):
	if not drag_card:
		var sv = card.get_node("SubViewport")
		mover.texture = sv.get_texture()
		mover.global_position = card.global_position + card.size / 2 - mover.size / 2
		mover.modulate.a = 1.0
		mover.show()


func _on_pool_card_mouse_exited(_card):
	if not drag_card:
		mover.hide()
