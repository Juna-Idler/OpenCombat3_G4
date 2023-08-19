extends IGameServer

class_name OfflineServer

const COMBAT_RESULT_DELAY = 5000
const COMBAT_SKILL_DELAY = 1000
const RECOVER_RESULT_DELAY = 1000


var _processor := GameProcessor.new()

var _player : OfflinePlayer
var _cpu_player : OfflinePlayer

var _player_name:String

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation

var _commander : ICpuCommander = null
var _result:int

var _player_time : int
var _emit_time : int
var _delay_time : int

var non_playable_recovery_phase : bool = false


func _init():
	pass

func initialize(name:String,deck:PackedInt32Array,
		commander : ICpuCommander,cpu_deck:PackedInt32Array,
		d_regulation :RegulationData.DeckRegulation,
		m_regulation :RegulationData.MatchRegulation,card_catalog : CardCatalog):
	_player_name = name;
	_commander = commander
	commander._set_deck_list(cpu_deck,deck)

	deck_regulation = d_regulation
	match_regulation = m_regulation
	
	var factory := PlayerCardFactory.new(card_catalog)
	var cpu_factory := PlayerCardFactory.new(card_catalog)
	
	_player = OfflinePlayer.new(factory,deck,m_regulation.hand_count,true)
	_cpu_player = OfflinePlayer.new(cpu_factory,cpu_deck,m_regulation.hand_count,true)
	

func _get_primary_data() -> PrimaryData:
	var my_deck_list : PackedInt32Array = []
	for c in _player._get_deck_list():
		my_deck_list.append(c.data.id)
	var r_deck_list  : PackedInt32Array = []
	for c in _cpu_player._get_deck_list():
		r_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,
			_commander._get_commander_name(),r_deck_list,
			deck_regulation,match_regulation)

func _send_ready():

	var first := _processor.standby(_player,_cpu_player)
	first.myself.time = match_regulation.thinking_time

	_result = _commander._first_select(_cpu_player._get_hand(),_player._get_hand())
	
	_emit_time = Time.get_ticks_msec()
	recieved_first_data.emit(first)
	_player_time = int(match_regulation.thinking_time * 1000)
	_delay_time = int(match_regulation.combat_time * 1000) + 1000



func _send_combat_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	var elapsed = Time.get_ticks_msec() - _emit_time
	if elapsed > _delay_time:
		_player_time -= elapsed - _delay_time
		if _player_time < 0:
#			index = 0
#			hands_order = []
			_player_time = 0

	var index2 = _result
# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.COMBAT:
		return
	if not hands_order.is_empty():
		_processor.reorder_hand1(hands_order)

	var combat_result := _processor.combat(index,index2)
	
	combat_result.myself.time = _player_time / 1000.0
	combat_result.rival.time = -1

	var skill_count := OfflineServer.count_effect(combat_result.myself) + OfflineServer.count_effect(combat_result.rival)
	_delay_time = skill_count * COMBAT_SKILL_DELAY + COMBAT_RESULT_DELAY
	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(OfflineServer.create_commander_player(_processor.player2),
				OfflineServer.create_commander_player(_processor.player1));
		_delay_time += int(match_regulation.combat_time * 1000)
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(OfflineServer.create_commander_player(_processor.player2),
					OfflineServer.create_commander_player(_processor.player1))
			if _processor.player1._is_recovery():
				non_playable_recovery_phase = true
		else:
			_result = -1
		_delay_time += int(match_regulation.recovery_time * 1000)
	
	_emit_time = Time.get_ticks_msec()
	recieved_combat_result.emit(combat_result)


static func count_effect(pd : IGameServer.CombatData.PlayerData) -> int:
	return pd.before.size() + pd.moment.size() + pd.after.size() + pd.end.size() + pd.start.size()


static func create_commander_player(player : MechanicsData.IPlayer) -> ICpuCommander.Player:
	return ICpuCommander.Player.new(player._get_hand(),player._get_played(),
			player._get_discard(),player._get_stock_count(),player._get_life(),
			player._get_enchants())
	


func _send_recovery_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	if index >= 0:
		var elapsed = Time.get_ticks_msec() - _emit_time
		if elapsed > _delay_time:
			_player_time -= elapsed - _delay_time
			if _player_time < 0:
#				index = 0
#				hands_order = []
				_player_time = 0
	
	var index2 = _result
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.RECOVERY:
		return
	if not hands_order.is_empty():
		_processor.reorder_hand1(hands_order)

	var recovery_result := _processor.recover(index,index2)
	
	recovery_result.myself.time = _player_time / 1000.0
	recovery_result.rival.time = -1

	non_playable_recovery_phase = false
	if _processor.phase == Phase.COMBAT:
		_result = _commander._combat_select(OfflineServer.create_commander_player(_processor.player2),
				OfflineServer.create_commander_player(_processor.player1));
		_delay_time = int(match_regulation.combat_time * 1000) + RECOVER_RESULT_DELAY
	elif _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			_result = _commander._recover_select(OfflineServer.create_commander_player(_processor.player2),
					OfflineServer.create_commander_player(_processor.player1))
			if _processor.player1._is_recovery():
				non_playable_recovery_phase = true
		else:
			_result = -1
		_delay_time = int(match_regulation.recovery_time * 1000) + RECOVER_RESULT_DELAY
			
	_emit_time = Time.get_ticks_msec()
	recieved_recovery_result.emit(recovery_result)


func _send_surrender():
	recieved_end.emit("You surrender")


