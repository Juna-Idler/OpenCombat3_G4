extends Node


signal performed()

var _performing : bool


var _game_server : IGameServer = null

var _myself : I_MatchPlayer
var _rival : I_MatchPlayer


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
		my_catalog : I_CardCatalog,rival_catalog : I_CardCatalog,
		myself : I_MatchPlayer,rival : I_MatchPlayer):
	terminalize()
	_game_server = server
	_game_server.recieved_first_data.connect(_on_recieved_first_data)
	_game_server.recieved_combat_result.connect(_on_recieved_combat_result)
	_game_server.recieved_recovery_result.connect(_on_recieved_recovery_result)
	_game_server.recieved_end.connect(_on_recieved_end)
	_game_server.recieved_complete_board.connect(_on_recieved_complete_board)

	_myself = myself
	_rival = rival
	$Field.add_child(_myself._get_scene())
	$Field.add_child(_rival._get_scene())
	_rival._get_scene().rotation_degrees.z = 180

	var pd := _game_server._get_primary_data()

	_myself._initialize(pd.my_name,pd.my_deck_list,my_catalog)
	_rival._initialize(pd.rival_name,pd.rival_deck_list,rival_catalog)
	

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



func _on_recieved_first_data(first_data : IGameServer.FirstData):
	_performing = true
	_myself._set_first_data(first_data.myself)
	_rival._set_first_data(first_data.rival)
	
	await get_tree().create_timer(1).timeout
	_performing = false
	performed.emit()
	pass

		
func _on_recieved_combat_result(data : IGameServer.CombatData):
	_performing = true
	
	perform_effect_timing(data.myself.before,data.rival.before)

	perform_effect_timing(data.myself.moment,data.rival.moment)
	
	perform_effect_timing(data.myself.after,data.rival.after)
	
	perform_effect_timing(data.myself.end,data.rival.end)

	perform_effect_timing(data.myself.start,data.rival.start)
	
	_performing = false
	performed.emit()
	
func _on_recieved_recovery_result(data : IGameServer.RecoveryData):
	_performing = true


	perform_effect_timing(data.myself.start,data.rival.start)
	
	_performing = false
	performed.emit()
	
	
func _on_recieved_end(_msg:String):
	pass
	
func _on_recieved_complete_board(_data : IGameServer.CompleteData):
	pass


func perform_effect_timing(my_log : Array[IGameServer.EffectLog],
		rival_log : Array[IGameServer.EffectLog]):
	var mi : int = 0
	var ri : int = 0
	while (true):
		if mi == my_log.size():
			_rival._perform_effect(rival_log[ri],_myself)
			for i in range(ri,rival_log.size()):
				_rival._perform_effect(rival_log[i],_myself)
			break
		if ri == rival_log.size():
			_myself._perform_effect(my_log[mi],_rival)
			for i in range(mi,my_log.size()):
				_myself._perform_effect(my_log[i],_rival)
			break
		if my_log[mi].priority <= rival_log[ri].priority:
			_myself._perform_effect(my_log[mi],_rival)
			_rival._perform_effect(rival_log[ri],_myself)
		else:
			_rival._perform_effect(rival_log[ri],_myself)
			_myself._perform_effect(my_log[mi],_rival)
			
