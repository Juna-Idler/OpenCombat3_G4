extends Control


const Card := preload("res://game_client/deck_build/deck_list/card.tscn")
const BuildCard := preload("res://game_client/deck_build/building/card.tscn")

signal card_clicked(_index : int)

@onready var mover = %Mover

func initialize(items : Array[Texture2D],order : PackedInt32Array,editable : bool = true):
	terminalize()
	if order.size() != items.size():
		order = range(items.size())
	
	for i in order:
		var c := Card.instantiate()
		c.texture = items[order[i]]
		if editable:
			c.drag_start.connect(_on_card_drag_start)
			c.dragging.connect(_on_card_dragging)
			c.dropped.connect(_on_card_dropped)
		c.clicked.connect(_on_card_clicked)
		c.set_meta("index",order[i])
		%DeckListContainer.add_child(c)
	pass

func initialize_from_deck(deck : DeckData,order : PackedInt32Array,editable : bool = true):
	terminalize()
	if order.size() != deck.cards.size():
		order = range(deck.cards.size())
	
	for i in order:
		var c := BuildCard.instantiate()
		c.initialize(deck.catalog._get_card_data(deck.cards[order[i]]))
		if editable:
			c.drag_start.connect(_on_card_drag_start)
			c.dragging.connect(_on_card_dragging)
			c.dropped.connect(_on_card_dropped)
		c.clicked.connect(_on_card_clicked)
		c.set_meta("index",order[i])
		%DeckListContainer.add_child(c)
	pass

	
func terminalize():
	for c in %DeckListContainer.get_children():
		%DeckListContainer.remove_child(c)
		c.queue_free()

	
func get_order() -> PackedInt32Array:
	return %DeckListContainer.get_children().map(func(v):return v.get_meta("index",-1))


func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass



func _on_card_drag_start(_self, _pos):
	%DeckListContainer.drag_start(_self)
	
	_self.modulate.a = 0.1
	
	mover.show()
	mover.size = Vector2(142,200)
	mover.modulate.a = 1.0
	mover.global_position = get_global_mouse_position() - mover.size / 2
	mover.texture = _self.get_texture()




func _on_card_dragging(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckListContainer.make_canvas_position_local(pos)
	if Rect2(Vector2.ZERO,%DeckListContainer.size).has_point(point):
		%DeckListContainer.pointing(point)
	else:
#		%DeckListContainer.exit()
		pass

	mover.global_position = pos - mover.size / 2


func _on_card_dropped(_self, _relative_pos, _start_pos):
	var pos : Vector2 = get_global_mouse_position()
	var point : Vector2 = %DeckListContainer.make_canvas_position_local(pos)
	_self.modulate.a = 1.0
	_self.global_position = pos - _self.size / 2
	%DeckListContainer.drop(_self,point)
	
	mover.hide()



func _on_card_clicked(_self):
	card_clicked.emit(_self.get_meta("index"))
