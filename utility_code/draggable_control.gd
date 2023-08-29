extends Control


signal clicked(_self : Control)
signal held(_self : Control)
signal double_clicked(_self : Control)
signal drag_start(_self : Control,pos : Vector2)
signal dragging(_self : Control,relative_pos : Vector2,start_pos : Vector2)
signal dropped(_self : Control,relative_pos : Vector2,start_pos : Vector2)


@export var _timer : Timer = null
@export var _double_click_duration_ms : int = 0

var _holding := false

var _double_click_time : int = -_double_click_duration_ms - 1
var _click_count := 0

var _dragging := false
var _drag_point : Vector2

const drag_amount := 10 * 10

func _ready():
	pass # Replace with function body.


func _gui_input(event: InputEvent):
	if _holding:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and not event.pressed):
			_holding = false
			if _dragging:
				var point := (event as InputEventMouseButton).global_position
				var relative := point - (_drag_point + get_global_rect().position)
				_dragging = false
				dropped.emit(self,relative,_drag_point)
			else:
				if _timer != null and not _timer.is_stopped():
					_timer.stop()
					_timer.timeout.disconnect(_on_timer_timeout)
				if _double_click_duration_ms > 0:
					var time = Time.get_ticks_msec()
					if time - _double_click_time <= _double_click_duration_ms and _click_count == 2:
						_double_click_time = -_double_click_duration_ms-1
						_click_count = 0
						double_clicked.emit(self)
						return
				clicked.emit(self)
			
		elif event is InputEventMouseMotion:
			var point := (event as InputEventMouseMotion).global_position
			var relative := point - (_drag_point + get_global_rect().position)
			if not _dragging and relative.length_squared() >= drag_amount:
				_dragging = true
				drag_start.emit(self,_drag_point)
				if _timer != null and not _timer.is_stopped():
					_timer.stop()
					_timer.timeout.disconnect(_on_timer_timeout)
			if _dragging:
				dragging.emit(self,relative,_drag_point)
	else:
		if (event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed):
			_holding = true
			_drag_point = (event as InputEventMouseButton).position
			if _timer != null:
				_timer.start()
				_timer.timeout.connect(_on_timer_timeout,CONNECT_ONE_SHOT)
			if _double_click_duration_ms > 0:
				var time = Time.get_ticks_msec()
				if time - _double_click_time > _double_click_duration_ms:
					_double_click_time = time
					_click_count = 0
				_click_count += 1

func _on_timer_timeout():
	_holding = false
	held.emit(self)

func cancel():
	if _timer != null and not _timer.is_stopped():
		_timer.stop()
		_timer.timeout.disconnect(_on_timer_timeout)
	_dragging = false
	_holding = false

