extends Node


signal performed

var _performing : bool


var _game_server : IGameServer = null

var _myself : I_PlayerField
var _rival : I_PlayerField

var round_count : int
var phase : IGameServer.Phase
var recovery_repeat : int

@onready var power_balance = %PowerBalance
@onready var log_display : LogDisplay  = %LogDisplay


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initialize(server : IGameServer,
		myself : I_PlayerField,rival : I_PlayerField,
		my_catalog : I_CardCatalog,rival_catalog : I_CardCatalog):
	terminalize()
	_game_server = server
	_game_server.recieved_first_data.connect(_on_recieved_first_data)
	_game_server.recieved_combat_result.connect(_on_recieved_combat_result)
	_game_server.recieved_recovery_result.connect(_on_recieved_recovery_result)
	_game_server.recieved_end.connect(_on_recieved_end)
	_game_server.recieved_complete_board.connect(_on_recieved_complete_board)

	_myself = myself
	_rival = rival
	$Field.add_child(_myself)
	$Field.add_child(_rival)

	var pd := _game_server._get_primary_data()
	
	log_display.clear()

	_myself._initialize(pd.my_name,pd.my_deck_list,my_catalog,false,
			CombatPowerBalance.Interface.new(power_balance,false),
			log_display)
	_rival._initialize(pd.rival_name,pd.rival_deck_list,rival_catalog,true,
			CombatPowerBalance.Interface.new(power_balance,true),
			log_display)
	_myself._set_rival(_rival)
	_rival._set_rival(_myself)
	
	power_balance.visible = false
	power_balance.modulate.a = 0

func terminalize():
	if _game_server:
		_game_server.recieved_first_data.disconnect(_on_recieved_first_data)
		_game_server.recieved_combat_result.disconnect(_on_recieved_combat_result)
		_game_server.recieved_recovery_result.disconnect(_on_recieved_recovery_result)
		_game_server.recieved_end.disconnect(_on_recieved_end)
		_game_server.recieved_complete_board.disconnect(_on_recieved_complete_board)
		_game_server = null
		
	if _myself:
		$Field.remove_child(_myself)
		_myself.queue_free()
		_myself = null
	if _rival:
		$Field.remove_child(_rival)
		_rival.queue_free()
		_rival = null


func _on_recieved_first_data(data : IGameServer.FirstData):
	_performing = true
	round_count = 1
	phase = IGameServer.Phase.COMBAT
	recovery_repeat = 0
	
	await perform_effect(data.myself.initial,data.rival.initial,I_PlayerField.EffectTiming.INITIAL)

	_myself._set_first_data(data.myself)
	_rival._set_first_data(data.rival)
	await get_tree().create_timer(1).timeout

	log_display.append_round(round_count)

	await perform_effect(data.myself.start,data.rival.start,I_PlayerField.EffectTiming.START)
	
	_performing = false
	performed.emit()
	pass

		
func _on_recieved_combat_result(data : IGameServer.CombatData):
	
	_performing = true
	_myself._combat_start(data.myself.hand,data.myself.select)
	_rival._combat_start(data.rival.hand,data.rival.select)
	log_display.append_combat_start(_myself._get_playing_card().card_name,_rival._get_playing_card().card_name)
	
	await get_tree().create_timer(1.0).timeout
	
#	power_balance.visible = true
	power_balance.change_both_power(0,0,0.0)
	var tween = create_tween()
	tween.tween_property(power_balance,"modulate:a",1.0,0.5)
	power_balance.change_both_power(
			_myself._get_playing_card().power,_rival._get_playing_card().power,0.5)
	await tween.finished

	await perform_effect(data.myself.before,data.rival.before,I_PlayerField.EffectTiming.BEFORE)

	log_display.append_combat_comparison_effect()
	_myself._perform_simultaneous_initiative(data.myself.comparison.fragment[0],0.3)
	_rival._perform_simultaneous_initiative(data.rival.comparison.fragment[0],0.3)
	await get_tree().create_timer(0.5).timeout

	await perform_effect(data.myself.moment,data.rival.moment,I_PlayerField.EffectTiming.MOMENT)

	log_display.append_combat_result_effect()

	await _myself._perform_effect(data.myself.result)
	await _rival._perform_effect(data.rival.result)

	await perform_effect(data.myself.after,data.rival.after,I_PlayerField.EffectTiming.AFTER)
	
	if data.next_phase == IGameServer.Phase.GAME_END:
		power_balance.visible = false
		phase = data.next_phase
		_performing = false
		performed.emit()
		return
	
	await perform_effect(data.myself.end,data.rival.end,I_PlayerField.EffectTiming.END)
	

	tween = create_tween()
	tween.tween_property(power_balance,"modulate:a",0.0,0.5)
	tween.tween_callback(func():power_balance.visible = false)
	_myself._combat_end()
	_rival._combat_end()
	await tween.finished

	log_display.append_combat_supply_effect()
	var duration := maxf(_myself._perform_simultaneous_supply(data.myself.supply,0.5),
			_rival._perform_simultaneous_supply(data.rival.supply,0.5))
	await get_tree().create_timer(duration).timeout

	if data.next_phase == IGameServer.Phase.COMBAT:
		round_count = data.round_count + 1
		log_display.append_round(round_count)
		await perform_effect(data.myself.start,data.rival.start,I_PlayerField.EffectTiming.START)
	else:
		if data.next_phase == IGameServer.Phase.RECOVERY:
#			player.set_damage
			log_display.append_enter_recovery(data.myself.damage,data.rival.damage)
		round_count = data.round_count
	phase = data.next_phase
	
	_performing = false
	performed.emit()
	
func _on_recieved_recovery_result(data : IGameServer.RecoveryData):
	_performing = true
	
	log_display.append_recovery_result_effect()

	await _myself._perform_effect(data.myself.result)
	await _rival._perform_effect(data.rival.result)

	if data.next_phase == IGameServer.Phase.COMBAT:
		round_count = data.round_count + 1
		log_display.append_round(round_count)
	else:
		if data.next_phase == IGameServer.Phase.RECOVERY:
#			player.set_damage
			log_display.append_enter_recovery(data.myself.damage,data.rival.damage)
		round_count = data.round_count
	phase = data.next_phase
	recovery_repeat = data.repeat
	
	await perform_effect(data.myself.start,data.rival.start,I_PlayerField.EffectTiming.START)
	
	_performing = false
	performed.emit()
	
	
func _on_recieved_end(_msg:String):
	pass
	
func _on_recieved_complete_board(_data : IGameServer.CompleteData):
	pass


func perform_effect(my_log : Array[IGameServer.EffectLog],
		rival_log : Array[IGameServer.EffectLog],timing : I_PlayerField.EffectTiming):
	await _myself._begin_timing(timing)
	await _rival._begin_timing(timing)
	
	log_display.append_timing(timing)

	var mi : int = 0
	var ri : int = 0
	while (true):
		if mi == my_log.size():
			for i in range(ri,rival_log.size()):
				await _rival._perform_effect(rival_log[i])
			break
		if ri == rival_log.size():
			for i in range(mi,my_log.size()):
				await _myself._perform_effect(my_log[i])
			break
		if my_log[mi].priority <= rival_log[ri].priority:
			await _myself._perform_effect(my_log[mi])
			await _rival._perform_effect(rival_log[ri])
		else:
			await _rival._perform_effect(rival_log[ri])
			await _myself._perform_effect(my_log[mi])
		mi += 1
		ri += 1
		
	await _myself._finish_timing(timing)
	await _rival._finish_timing(timing)




func _on_button_log_toggled(button_pressed):
	if button_pressed:
		%LogDisplay.visible = true
		%LogDisplay.open.call_deferred()
		var tween := create_tween()
		tween.tween_property($CanvasLayer/Control/Control,"position:x",0,0.3)
		pass
	else:
		var tween := create_tween()
		tween.tween_property($CanvasLayer/Control/Control,"position:x",-480,0.2)
		tween.tween_callback(func():%LogDisplay.visible = false)
		pass
	pass # Replace with function body.
