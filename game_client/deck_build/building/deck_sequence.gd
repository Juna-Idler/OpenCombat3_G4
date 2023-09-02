@tool

extends Container

@export var card_width := 142.0 :
	set(v):
		card_width = v
		queue_sort()
@export var card_height := 200.0 :
	set(v):
		card_height = v
		custom_minimum_size.y = card_height + top_margin + bottom_margin
		for c in get_children():
			c.size.y = card_height
		reset_size()
@export var card_space := 16.0 :
	set(v):
		card_space = v
		queue_sort()
@export var side_margin := 16.0 :
	set(v):
		side_margin = v
		queue_sort()
@export var top_margin := 8.0 :
	set(v):
		top_margin = v
		custom_minimum_size.y = card_height + top_margin + bottom_margin
		for c in get_children():
			c.position.y = top_margin
		reset_size()
@export var bottom_margin := 8.0 :
	set(v):
		bottom_margin = v
		custom_minimum_size.y = card_height + top_margin + bottom_margin
		reset_size()


var _tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():

	_tween = create_tween()
	_tween.kill()

	for c in get_children():
		c.position.y = top_margin



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func set_some_setting():
	# Some setting changed, ask for children re-sort
	queue_sort()
	

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var count := get_child_count()
		if count == 0:
			return
		_tween.kill()
		_tween = create_tween().set_parallel()
		for i in count:
			var c : Control = get_child(i)
			c.size = Vector2(card_width,card_height)
			var pos := Vector2(side_margin + (card_width + card_space) * i,top_margin)
			_tween.tween_property(c,"position",pos,0.5)
	#		fit_child_in_rect( c, Rect2( Vector2(x,0), Vector2(card_width,card_height) ) )

func _get_minimum_size() -> Vector2:
	var count := get_child_count()
	count += int(count == 0)
	var min_size = Vector2(side_margin + (card_width + card_space) * count - card_space + side_margin,
				card_height + top_margin + bottom_margin)
	return min_size


#func _gui_input(event: InputEvent):
#	if event is InputEventMouseMotion:
#		var point := (event as InputEventMouseMotion).position
##		pointing(point)
#		print(point)
#		print(get_local_mouse_position())
#		print(make_canvas_position_local(get_global_mouse_position()))
#		pass

var _dragging := -2

func drag_start(c : Control):
	_dragging = get_children().find(c)


var _last_area := -1

func pointing(point : Vector2):
	var count := get_child_count()
	var area := floori((point.x - card_width / 2 - side_margin) / (card_width + card_space)) + 1
	area = mini(area,count)
	if area != _last_area:
		if count == 0:
			return
		_tween.kill()
		_tween = create_tween().set_parallel()
		if area == _dragging or area == _dragging + 1:
			for i in count:
				var c : Control = get_child(i)
				var x := side_margin + (card_width + card_space) * i
				_tween.tween_property(c,"position:x",x,0.5)
		else:
			for i in count:
				var c : Control = get_child(i)
				var x := side_margin + (card_width + card_space) * i
				if i < area:
					x -= card_width * 0.5 / (1.0 + (area - i) * 0.25)
				else:
					x += card_width * 0.5 / (1.0 + (i - area + 1) * 0.25)
				_tween.tween_property(c,"position:x",x,0.5)
		
	_last_area = area

func not_pointing():
	if _last_area != -1:
		queue_sort()
		_last_area = -1
	

func drop(card : Control,point : Vector2):
	var area := floori((point.x - card_width / 2 - side_margin) / (card_width + card_space)) + 1
	area = mini(area,get_child_count())
	var f := get_children().find(card)
	if f >= 0:
		if f < area:
			area -= 1
	else:
		add_child(card)
		card.position = point - card.size / 2
	move_child(card,area)
	queue_sort()
	_last_area = -1
	_dragging = -2

func exit():
	if _last_area != -1:
		queue_sort()
		_last_area = -1
	_dragging = -2
	

func add_card(card : Control):
	add_child(card)
	card.position = Vector2(side_margin + (card_width + card_space) * (get_child_count() - 1),top_margin)
	card.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(card,"modulate:a",1.0,0.5)
	queue_sort()
	
