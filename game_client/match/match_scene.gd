extends Node


signal performed

var _performing : bool


var _game_server : IGameServer = null

var _myself : I_MatchPlayer
var _rival : I_MatchPlayer

var round_count : int
var phase : IGameServer.Phase
var recovery_repeat : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#	var catalog = CardCatalog.new()
#	var id : int = 1
#	var pile : Array[int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]
#
#	playable_player.initialize("",pile,catalog)
#	var fd := IGameServer.FirstData.PlayerData.new([1,2,3,4],20,-1)
#	playable_player.set_first_data(fd)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initialize(server : IGameServer,
		myself : I_MatchPlayer,rival : I_MatchPlayer,
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
	$Field.add_child(_myself._get_field())
	$Field.add_child(_rival._get_field())

	var pd := _game_server._get_primary_data()

	_myself._initialize(pd.my_name,pd.my_deck_list,my_catalog,false,
			CombatPowerBalance.Interface.new($Control/power_balance,false))
	_rival._initialize(pd.rival_name,pd.rival_deck_list,rival_catalog,true,
			CombatPowerBalance.Interface.new($Control/power_balance,true))
	_myself._set_rival(_rival)
	_rival._set_rival(_myself)
	
	$Control/power_balance.visible = false
	$Control/power_balance.modulate.a = 0

func terminalize():
	if _game_server:
		_game_server.recieved_first_data.disconnect(_on_recieved_first_data)
		_game_server.recieved_combat_result.disconnect(_on_recieved_combat_result)
		_game_server.recieved_recovery_result.disconnect(_on_recieved_recovery_result)
		_game_server.recieved_end.disconnect(_on_recieved_end)
		_game_server.recieved_complete_board.disconnect(_on_recieved_complete_board)
		_game_server = null
		
	if _myself:
		$Field.remove_child(_myself._get_scene())
		_myself = null
	if _rival:
		$Field.remove_child(_rival._get_scene())
		_rival = null



func _on_recieved_first_data(data : IGameServer.FirstData):
	_performing = true
	round_count = 1
	phase = IGameServer.Phase.COMBAT
	recovery_repeat = 0
	
	await perform_effect(data.myself.initial,data.rival.initial,I_MatchPlayer.EffectTiming.INITIAL)

	_myself._set_first_data(data.myself)
	_rival._set_first_data(data.rival)
	await get_tree().create_timer(1).timeout

	await perform_effect(data.myself.start,data.rival.start,I_MatchPlayer.EffectTiming.START)
	
	_performing = false
	performed.emit()
	pass

		
func _on_recieved_combat_result(data : IGameServer.CombatData):
	
	_performing = true
	_myself._combat_start(data.myself.hand,data.myself.select)
	_rival._combat_start(data.rival.hand,data.rival.select)
	$Control/power_balance.visible = true
	$Control/power_balance.change_both_power(0,0,0.0)
	var tween = create_tween()
	tween.tween_property($Control/power_balance,"modulate:a",1.0,0.5)
	$Control/power_balance.change_both_power(
			_myself._get_playing_card().power,_rival._get_playing_card().power,0.5)
	await tween.finished

	await perform_effect(data.myself.before,data.rival.before,I_MatchPlayer.EffectTiming.BEFORE)

	await perform_effect(data.myself.moment,data.rival.moment,I_MatchPlayer.EffectTiming.MOMENT)

	await _myself._perform_effect(data.myself.result)
	await _rival._perform_effect(data.rival.result)
#	await get_tree().create_timer(0.5).timeout

	await perform_effect(data.myself.after,data.rival.after,I_MatchPlayer.EffectTiming.AFTER)
	
	await perform_effect(data.myself.end,data.rival.end,I_MatchPlayer.EffectTiming.END)
	

	tween = create_tween()
	tween.tween_property($Control/power_balance,"modulate:a",0.0,0.5)
	tween.tween_callback(func():$Control/power_balance.visible = false)
	_myself._combat_end()
	_rival._combat_end()
	await tween.finished

	round_count = data.round_count + (1 if data.next_phase == IGameServer.Phase.COMBAT else 0)
	phase = data.next_phase
	
	await perform_effect(data.myself.start,data.rival.start,I_MatchPlayer.EffectTiming.START)
	
	_performing = false
	performed.emit()
	
func _on_recieved_recovery_result(data : IGameServer.RecoveryData):
	_performing = true

	_myself._perform_effect(data.myself.result)
	_rival._perform_effect(data.rival.result)
	await get_tree().create_timer(0.5).timeout


	round_count = data.round_count + (1 if data.next_phase == IGameServer.Phase.COMBAT else 0)
	phase = data.next_phase
	recovery_repeat = data.repeat
	
	await perform_effect(data.myself.start,data.rival.start,I_MatchPlayer.EffectTiming.START)
	
	_performing = false
	performed.emit()
	
	
func _on_recieved_end(_msg:String):
	pass
	
func _on_recieved_complete_board(_data : IGameServer.CompleteData):
	pass


func perform_effect(my_log : Array[IGameServer.EffectLog],
		rival_log : Array[IGameServer.EffectLog],timing : I_MatchPlayer.EffectTiming):
	await _myself._begin_timing(timing)
	await _rival._begin_timing(timing)
	
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


