extends Panel


signal exit
signal saved(deck : DeckData)

signal request_card_detail(cd : CatalogData.CardData)
signal request_deck_list(deck : DeckData)


@onready var mover = %Mover

var mover_tween : Tween

var drag_card : Control = null

var catalog : I_CardCatalog = null
var list : PackedInt32Array = []
var list_page : int = 0
var list_page_max : int = 1


func initialize(deck : DeckData):
	$VBoxContainer/Header/LineEditName.text = deck.name
	catalog = deck.catalog
	list = catalog._get_card_id_list()
	list_page = 0
	list_page_max = ceili(list.size() / 18.0)
	$VBoxContainer/Footer/BoxContainer/Label.text = "/" + str(list_page_max)
	
	for c in %DeckSequence.get_children():
		%DeckSequence.remove_child(c)
		c.queue_free()
	for i in deck.cards:
		var c := _create_deck_card(catalog._get_card_data(i))
		%DeckSequence.add_card(c)

	var i := 0
	for c in %GridContainer.get_children():
		if i  < list.size():
			var cd := Global.card_catalog._get_card_data(list[i])
			c.initialize(cd)
		else:
			c.hide()
		i += 1
		
	pass


func _create_deck_card(cd : CatalogData.CardData) -> Control:
	const DeckCard := preload("res://game_client/deck_build/building/card.tscn")
	var c := DeckCard.instantiate()
	c.drag_start.connect(_on_card_drag_start)
	c.dragging.connect(_on_card_dragging)
	c.dropped.connect(_on_card_dropped)
	c.held.connect(_on_card_held)
	c.timer = $Timer
	c.initialize(cd)
	return c


# Called when the node enters the scene tree for the first time.
func _ready():
	for c in %GridContainer.get_children():
		c.drag_start.connect(_on_pool_card_drag_start)
		c.dragging.connect(_on_pool_card_dragging)
		c.dropped.connect(_on_pool_card_dropped)
		c.mouse_entered.connect(_on_pool_card_mouse_entered.bind(c))
		c.mouse_exited.connect(_on_pool_card_mouse_exited.bind(c))
		c.double_clicked.connect(_on_pool_card_double_clicked)
		c.held.connect(_on_card_held)
		c.double_click_duration_ms = 500
		c.timer = $Timer
	
	mover_tween = create_tween()
	mover_tween.kill()


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
	mover.scale = Vector2(0.71,0.71)
	mover.modulate.a = 1.0
	mover.global_position = get_global_mouse_position() - mover.size / 2
	mover.texture = _self.get_texture()
	mover.mouse_filter = MOUSE_FILTER_STOP
	
	drag_card = _self


func _on_card_dragging(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		%DeckSequence.pointing(point)
		mover.modulate.a = 1.0
	else:
		%DeckSequence.not_pointing()
		mover.modulate.a = 0.3

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
	mover.mouse_filter = MOUSE_FILTER_IGNORE


func _on_pool_card_drag_start(_self, _pos):
	drag_card = _self
	drag_card.modulate.a = 0.5
	mover.show()
	mover.scale = Vector2(0.71,0.71)
	mover.modulate.a = 1.0
	mover.global_position = get_global_mouse_position() - mover.size / 2
	
	mover.texture = _self.get_texture()
	mover.mouse_filter = MOUSE_FILTER_STOP


func _on_pool_card_dragging(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		%DeckSequence.pointing(point)
	else:
		%DeckSequence.not_pointing()
	mover.global_position = pos - mover.size / 2


func _on_pool_card_dropped(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckSequence.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckSequence.size).has_point(point):
		var c := _create_deck_card(_self.get_card_data())
		%DeckSequence.drop(c,point)
	else:
		%DeckSequence.exit()
	drag_card.modulate.a = 1.0
	drag_card = null
	mover.hide()
	mover.mouse_filter = MOUSE_FILTER_IGNORE


func _on_pool_card_mouse_entered(card):
	if not drag_card:
		mover.texture = card.get_texture()
		mover.global_position = card.global_position + card.size / 2 - mover.size / 2
		mover.modulate.a = 1.0
		mover.show()
		mover.scale = Vector2(0.71,0.71)
		mover_tween.kill()
		mover_tween = create_tween()
		mover_tween.tween_property(mover,"scale",Vector2(1.0,1.0),0.1)


func _on_pool_card_mouse_exited(_card):
	if not drag_card:
		mover.hide()



func _on_pool_card_double_clicked(_self):
	var c := _create_deck_card(_self.get_card_data())
	var dsize = %DeckSequence.size.x + %DeckSequence.card_width + %DeckSequence.card_space
	%DeckSequence.add_card(c)
	
	var tween := create_tween()
	tween.tween_property(%ScrollContainer,"scroll_horizontal",maxf(dsize - %ScrollContainer.size.x,0),0.5)


func _on_card_held(_self):
	request_card_detail.emit(_self.get_card_data())


func _on_button_page_plus_pressed():
	list_page += 1
	if list_page >= list_page_max:
		list_page = list_page_max - 1
	
	%LineEditPageNumber.text = str(list_page + 1)
	
	var i := list_page * 18
	for c in %GridContainer.get_children():
		if i  < list.size():
			var cd := Global.card_catalog._get_card_data(list[i])
			c.initialize(cd)
			c.show()
		else:
			c.hide()

		i += 1


func _on_button_page_minus_pressed():
	list_page -= 1
	if list_page < 0:
		list_page = 0
	%LineEditPageNumber.text = str(list_page + 1)
	var i := list_page * 18
	for c in %GridContainer.get_children():
		if i  < list.size():
			var cd := Global.card_catalog._get_card_data(list[i])
			c.initialize(cd)
			c.show()
		else:
			c.hide()
		i += 1


func _on_line_edit_page_number_text_submitted(new_text : String):
	if not new_text.is_valid_int():
		return
	list_page = new_text.to_int() - 1
	list_page = clampi(list_page,0,list_page_max - 1)
	var i := list_page * 18
	for c in %GridContainer.get_children():
		if i  < list.size():
			var cd := Global.card_catalog._get_card_data(list[i])
			c.initialize(cd)
			c.show()
		else:
			c.hide()
		i += 1



func _on_button_back_pressed():
	exit.emit()


func _on_button_save_pressed():
	var cards : PackedInt32Array = []
	for c in %DeckSequence.get_children():
		var cd := c.card_data as CatalogData.CardData
		cards.append(cd.id)
	saved.emit(DeckData.new($VBoxContainer/Header/LineEditName.text,catalog,cards))


func _on_button_list_pressed():
	var cards : PackedInt32Array = []
	for c in %DeckSequence.get_children():
		var cd := c.card_data as CatalogData.CardData
		cards.append(cd.id)
	request_deck_list.emit(DeckData.new($VBoxContainer/Header/LineEditName.text,catalog,cards))
	process_mode = Node.PROCESS_MODE_DISABLED

func reset_card_order(order : PackedInt32Array):
	var cards : Array = %DeckSequence.get_children().duplicate()
	order.reverse()
	for i in order:
		%DeckSequence.move_child(cards[i],0)
	process_mode = Node.PROCESS_MODE_INHERIT


