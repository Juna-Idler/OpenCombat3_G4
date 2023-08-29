@tool

extends Container

@export var card_width := 142.0 :
	set(v):
		card_width = v
		queue_sort()
@export var card_heith := 200.0 :
	set(v):
		card_heith = v
		custom_minimum_size.y = card_heith + top_margin + bottom_margin
		for c in get_children():
			c.size.y = card_heith
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
		custom_minimum_size.y = card_heith + top_margin + bottom_margin
		for c in get_children():
			c.position.y = top_margin
		reset_size()
@export var bottom_margin := 8.0 :
	set(v):
		bottom_margin = v
		custom_minimum_size.y = card_heith + top_margin + bottom_margin
		reset_size()


var _tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():

	_tween = create_tween()
	_tween.kill()
	


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
			c.size = Vector2(card_width,card_heith)
			c.position.y = top_margin
			var x := side_margin + (card_width + card_space) * i
			_tween.tween_property(c,"position:x",x,0.5)
	#		fit_child_in_rect( c, Rect2( Vector2(x,0), Vector2(card_width,card_heith) ) )

func _get_minimum_size() -> Vector2:
	var count := get_child_count()
	count += int(count == 0)
	var min_size = Vector2(side_margin + (card_width + card_space) * count - card_space + side_margin,
				card_heith + top_margin + bottom_margin)
	return min_size


#func _gui_input(event: InputEvent):
#	if event is InputEventMouseMotion:
#		var point := (event as InputEventMouseMotion).position
##		pointing(point)
#		print(point)
#		print(get_local_mouse_position())
#		print(make_canvas_position_local(get_global_mouse_position()))
#		pass
#	pass # Replace with function body.

var _last_area := -1
func pointing(point : Vector2):
	var area := floori((point.x - card_width / 2 - side_margin) / (card_width + card_space)) + 1
	print(area)
	print(get_rect())
	if area != _last_area:
		var count := get_child_count()
		if count == 0:
			return
		_tween.kill()
		_tween = create_tween().set_parallel()
		for i in count:
			var c : Control = get_child(i)
			var x := side_margin + (card_width + card_space) * i
			if i < area:
				x -= card_width * 0.8 / (area - i + 1)
			else:
				x += card_width * 0.8 / (i - area + 2)
			_tween.tween_property(c,"position:x",x,0.5)
		
		_last_area = area
	pass

func exit():
	queue_sort()
	_last_area = -1

func drop(point : Vector2):
	var area := floori((point.x - card_width / 2 - side_margin) / (card_width + card_space)) + 1
	queue_sort()
	_last_area = -1

