@tool

extends Container

@export var column := 9 :
	set(v):
		column = v
		queue_sort()

@export var card_width := 142.0 :
	set(v):
		card_width = v
		queue_sort()
@export var card_height := 200.0 :
	set(v):
		card_height = v
		queue_sort()

@export var card_x_space := 16.0 :
	set(v):
		card_x_space = v
		queue_sort()
@export var card_y_space := 16.0 :
	set(v):
		card_y_space = v
		queue_sort()
@export var side_margin := 16.0 :
	set(v):
		side_margin = v
		queue_sort()
@export var top_margin := 8.0 :
	set(v):
		top_margin = v
		queue_sort()
@export var bottom_margin := 8.0 :
	set(v):
		bottom_margin = v
		queue_sort()

@export var row_slide := 8.0 :
	set(v):
		row_slide = v
		queue_sort()


var _tween : Tween



# Called when the node enters the scene tree for the first time.
func _ready():

	_tween = create_tween()
	_tween.kill()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass




func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var count := get_child_count()
		if count == 0:
			return
		@warning_ignore("integer_division")
		var row = (count - 1) / column + 1
		
		var x_start := side_margin
		_tween.kill()
		_tween = create_tween().set_parallel()
		var i : int = 0
		for row_pos in row:
			for col_pos in column:
				var c : Control = get_child(i)
				c.size = Vector2(card_width,card_height)
				var pos := Vector2(x_start + (card_width + card_x_space) * col_pos,top_margin + (card_height + card_y_space) * row_pos)
				_tween.tween_property(c,"position",pos,0.5)
				i += 1
				if i == count:
					break
			x_start += row_slide
		

func _get_minimum_size() -> Vector2:
	var count := get_child_count()
	count += int(count == 0)
	
	var col := mini(count,column)
	@warning_ignore("integer_division")
	var row = (count - 1) / column + 1
	
	var x : float = side_margin + col * (card_width + card_x_space) - card_x_space + side_margin + row_slide * (row - 1)
	var y : float = top_margin + row * (card_height + card_y_space) - card_y_space + bottom_margin
	return Vector2(x,y)



var _child_count := 0
var _row := 0
var _dragging := Vector2i(-1,-1)
var _last_area := Vector2i(-1,-1)

func drag_start(c : Control):
	_child_count = get_child_count()
	if _child_count == 0:
		return
	@warning_ignore("integer_division")
	_row = (_child_count - 1) / column + 1
	var i := get_children().find(c)
	@warning_ignore("integer_division")
	_dragging.y = i / column
	_dragging.x = i % column



func pointing(point : Vector2):
	if _child_count == 0:
		return
	var area_y := clampi(floori((point.y - top_margin) / (card_height + card_x_space)),0,_row - 1)
	@warning_ignore("integer_division")
	var p_x : float = point.x - card_width / 2 - side_margin - row_slide * area_y
	var area_x := clampi(floori(p_x / (card_width + card_x_space)) + 1,0,column)
	if area_y * column + area_x > _child_count:
		area_x = _child_count - area_y * column
	if area_x != _last_area.x or area_y != _last_area.y:
		_tween.kill()
		_tween = create_tween().set_parallel()
		if (area_y == _dragging.y) and ((area_x == _dragging.x) or (area_x == _dragging.x + 1)):
			var x_start := side_margin
			var i : int = 0
			for row_pos in _row:
				for col_pos in column:
					var c : Control = get_child(i)
					c.size = Vector2(card_width,card_height)
					var pos := Vector2(x_start + (card_width + card_x_space) * col_pos,top_margin + (card_height + card_y_space) * row_pos)
					_tween.tween_property(c,"position",pos,0.5)
					i += 1
					if i == _child_count:
						break
				x_start += row_slide
		else:
			var x_start := side_margin
			var i : int = 0
			for row_pos in _row:
				if row_pos == area_y:
					for col_pos in column:
						var x := x_start + (card_width + card_x_space) * col_pos
						if col_pos < area_x:
							x -= card_width * 0.5 / (1.0 + (area_x - col_pos) * 0.25)
						else:
							x += card_width * 0.5 / (1.0 + (col_pos - area_x + 1) * 0.25)
						
						var c : Control = get_child(i)
						c.size = Vector2(card_width,card_height)
						var pos := Vector2(x,top_margin + (card_height + card_y_space) * row_pos)
						_tween.tween_property(c,"position",pos,0.5)
						i += 1
						if i == _child_count:
							break
				else:
					for col_pos in column:
						var c : Control = get_child(i)
						c.size = Vector2(card_width,card_height)
						var pos := Vector2(x_start + (card_width + card_x_space) * col_pos,top_margin + (card_height + card_y_space) * row_pos)
						_tween.tween_property(c,"position",pos,0.5)
						i += 1
						if i == _child_count:
							break
				x_start += row_slide

	_last_area = Vector2i(area_x,area_y)

func exit():
	if _last_area.y != -1:
		queue_sort()
		_last_area.y = -1
	_dragging.y = -1


func drop(card : Control,point : Vector2):
	var area_y := clampi(floori((point.y - top_margin) / (card_height + card_x_space)),0,_row - 1)
	@warning_ignore("integer_division")
	var p_x : float = point.x - card_width / 2 - side_margin - row_slide * area_y
	var area_x := clampi(floori(p_x / (card_width + card_x_space)) + 1,0,column)
	if area_y * column + area_x > _child_count:
		area_x = _child_count - area_y * column
	
	var move := area_y * column + area_x
	if move > _dragging.y * column + _dragging.x:
		move -= 1
	move_child(card,move)
	queue_sort()
	
	_last_area.y = -1
	_dragging.y = -1

func add_card(card : Control):
	add_child(card)
	queue_sort()
	
