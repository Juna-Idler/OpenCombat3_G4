extends SceneChanger.IScene

var _scene_changer : SceneChanger

var replay_server := ReplayServer.new()

var catalog := CardCatalog.new()

const NonPlayablePlayerFieldScene := preload("res://game_client/match/player/field/non_playable_field.tscn")

const ReplayLabel := preload("res://game_client/replay/replay_label.tscn")

@onready var match_scene : MatchScene = $match_scene


var myself : NonPlayablePlayerField
var rival : NonPlayablePlayerField


var _match_log : MatchLog

var _complete_board : Array[IGameServer.CompleteData]

enum ReplayMode {NONE,AUTO,NO_WAIT,STEP}
var replay_mode : ReplayMode = ReplayMode.NONE

var duration_last_performing : int
var performing_durations : Array = []

@onready var performing_counter : Timer = $TimerPerformingCounter
@onready var timer : Timer = $Timer

@onready var v_box_container : VBoxContainer = %VBoxContainer

func _ready():
	pass
#	initialize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
	var list := MatchLogFile.load_directory("user://replay")
	for l in list:
		var label := ReplayLabel.instantiate()
		label.initialize(l,"title")
		label.pressed.connect(func():
			replay_start(l)
			)
		v_box_container.add_child(label)


func replay_start(log : MatchLog):
	duration_last_performing = 0
	performing_durations = []
	_complete_board = []
	_match_log = log
	replay_mode = ReplayMode.AUTO
	%ButtonNoWait.set_pressed_no_signal(false)
	%ButtonPause.set_pressed_no_signal(false)
	%TabContainer.current_tab = 0
	%HSliderSpeed.value = 0.0
	%Settings.hide()
	timer.stop()
	
	$CanvasLayerMenu/InputShutter.show()
	replay_server.initialize(_match_log)
	myself = NonPlayablePlayerFieldScene.instantiate()
	rival = NonPlayablePlayerFieldScene.instantiate()
	match_scene.initialize(replay_server,myself,rival,catalog,catalog)
	if not match_scene.performed.is_connected(on_match_scene_performed):
		match_scene.performed.connect(on_match_scene_performed)
	if not match_scene.ended.is_connected(on_match_scene_ended):
		match_scene.ended.connect(on_match_scene_ended)
	
	var tween := create_tween()
	tween.tween_property($CanvasLayerMenu/Panel,"modulate:a",0.0,0.5)
	await tween.finished
	$CanvasLayerMenu.hide()
	
	performing_counter.start()
	replay_server._send_ready()
	

func _fade_in_finished():
	pass

func _terminalize():
	pass


func _on_timer_timeout():
	if replay_mode == ReplayMode.AUTO and\
			replay_server.step < _match_log.update_data.size():
		performing_counter.start()
		replay_server.step_forward()

func on_match_scene_performed():
	if match_scene.phase == IGameServer.Phase.GAME_END:
		return

	var p1 := myself.serialize()
	var p2 := rival.serialize()
	var board := IGameServer.CompleteData.new(match_scene.round_count,match_scene.phase,p1,p2)

	duration_last_performing = int((performing_counter.wait_time - performing_counter.time_left) * 1000)
	if replay_server.step == performing_durations.size():
		performing_durations.append(duration_last_performing)
		_complete_board.append(board)
	else:
		performing_durations[replay_server.step] = duration_last_performing
		_complete_board[replay_server.step] = board
	performing_counter.stop()
	start_auto_replay()


func start_auto_replay():
	var step = replay_server.step
	match replay_mode:
		ReplayMode.AUTO:
			if step < _match_log.update_data.size():
				var duration = _match_log.update_data[step].time
				if step > 0:
					duration -= _match_log.update_data[step-1].time
				duration -= performing_durations[step]
				timer.start(0.01 if duration <= 0 else duration / 1000.0)
			else:
				if _match_log.end_time > 0:
					var duration = _match_log.end_time - _match_log.update_data.back().time
					duration -= duration_last_performing
					timer.start(0.01 if duration <= 0 else duration / 1000.0)
		ReplayMode.NO_WAIT:
			performing_counter.start()
			replay_server.step_forward()
		ReplayMode.STEP:
			pass



	
func on_match_scene_ended(_msg : String):
	pass



func _on_setting_button_pressed():
	%Settings.show()
	pass # Replace with function body.

func _on_button_exit_pressed():
	$CanvasLayerMenu.show()
	$CanvasLayerMenu/InputShutter.show()
	replay_mode = ReplayMode.NONE
	timer.stop()
	if match_scene.is_performing():
		await match_scene.performed
		match_scene.terminalize()
	Engine.time_scale = 1.0

	var tween := create_tween()
	tween.tween_property($CanvasLayerMenu/Panel,"modulate:a",1.0,0.5)
	await tween.finished
	$CanvasLayerMenu/InputShutter.hide()


func _on_h_slider_speed_value_changed(value):
	Engine.time_scale = 2.0 ** value
	pass # Replace with function body.


func _on_button_pause_toggled(button_pressed):
	if button_pressed:
		if replay_mode == ReplayMode.AUTO:
			timer.stop()
		replay_mode = ReplayMode.STEP
		%TabContainer.current_tab = 1
	else:
		replay_mode = ReplayMode.NO_WAIT if %ButtonNoWait.pressed else ReplayMode.AUTO
		%TabContainer.current_tab = 0

	if not match_scene.is_performing():
		start_auto_replay()


func _on_button_no_wait_toggled(button_pressed):
	replay_mode = ReplayMode.NO_WAIT if button_pressed else ReplayMode.AUTO
	if not match_scene.is_performing():
		start_auto_replay()


func _on_button_step_back_pressed():
	if not match_scene.is_performing():
		match_scene._performing = true
		var step := replay_server.step_backward()
		myself.deserialize(_complete_board[step].myself,0.5)
		rival.deserialize(_complete_board[step].rival,0.5)
		match_scene.round_count = _complete_board[step].round_count
		match_scene.phase = _complete_board[step].next_phase
		await get_tree().create_timer(0.5).timeout
		match_scene._performing = false


func _on_button_step_pressed():
	if not match_scene.is_performing():
		performing_counter.start()
		replay_server.step_forward()


func _on_button_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])
	pass # Replace with function body.
