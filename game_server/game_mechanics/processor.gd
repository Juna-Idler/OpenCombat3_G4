
class_name GameProcessor


var round_count : int
var phase : IGameServer.Phase
var recovery_count : int
var player1 : MechanicsData.IPlayer
var player2 : MechanicsData.IPlayer


class EffectOrder:
	var effect : MechanicsData.IEffect
	var priority : int
	var myself : MechanicsData.IPlayer
	var rival : MechanicsData.IPlayer

	func _init(e : MechanicsData.IEffect,p:int,
			m:MechanicsData.IPlayer,r:MechanicsData.IPlayer):
		effect = e
		priority = p
		myself = m
		rival = r
		
	static func custom_compare(a : EffectOrder, b : EffectOrder):
		return a.priority < b.priority


func _init():
	pass


func standby(p1 : MechanicsData.IPlayer,p2 : MechanicsData.IPlayer) -> IGameServer.FirstData:
	round_count = 1
	phase = IGameServer.Phase.COMBAT;
	player1 = p1
	player2 = p2
	
	#initial effect
	var p1_initial : Array[IGameServer.EffectLog] = []
	var p2_initial : Array[IGameServer.EffectLog] = []

	player1._start_effect_log_temporary().clear()
	player2._start_effect_log_temporary().clear()
	_start_effect()
	
	return IGameServer.FirstData.new(
			IGameServer.FirstData.PlayerData.new(player1._get_hand(),
			player1._get_life(),-1,p1_initial,player1._start_effect_log_temporary()),
			IGameServer.FirstData.PlayerData.new(player2._get_hand(),
			player2._get_life(),-1,p2_initial,player2._start_effect_log_temporary()))


func reorder_hand1(hand:PackedInt32Array):
	player1._change_order(hand)

func reorder_hand2(hand:PackedInt32Array):
	player2._change_order(hand)


func combat(index1 : int,index2 : int) -> IGameServer.CombatData:
	var current_round_count := round_count
	
	if phase != IGameServer.Phase.COMBAT:
		return null
	
	index1 = mini(maxi(0, index1), player1._get_hand().size() - 1);
	index2 = mini(maxi(0, index2), player2._get_hand().size() - 1);

	player1._start_effect_log_temporary().clear()
	player1._before_effect_log_temporary().clear()
	player1._moment_effect_log_temporary().clear()
	player1._after_effect_log_temporary().clear()
	player1._end_effect_log_temporary().clear()

	player2._start_effect_log_temporary().clear()
	player2._before_effect_log_temporary().clear()
	player2._moment_effect_log_temporary().clear()
	player2._after_effect_log_temporary().clear()
	player2._end_effect_log_temporary().clear()

	var p1_hand := player1._get_hand().duplicate()
	var p2_hand := player2._get_hand().duplicate()


	player1._combat_start(index1)
	player2._combat_start(index2)

	_before_effect()
	
	var situation := player1._get_current_power() - player2._get_current_power();
	var p1_comparison := IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,
			[player1._set_initiative(situation > 0)])
	var p2_comparison := IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,
			[player2._set_initiative(situation < 0)])

	_moment_effect()

	var p1_result := IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
	var p2_result := IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
	if (player1._has_initiative()):
		p1_result.fragment.append(player2._add_damage(player1._get_current_hit()))
	if (player2._has_initiative()):
		p2_result.fragment.append(player1._add_damage(player2._get_current_hit()))

	_after_effect()

	var p1fatal := player1._damage_is_fatal()
	var p2fatal := player2._damage_is_fatal()

	var p1_supply : IGameServer.EffectLog
	var p2_supply : IGameServer.EffectLog

	if p1fatal or p2fatal:
		phase = IGameServer.Phase.GAME_END
		p1_supply = IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
		p2_supply = IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
	else:
		_end_effect()
		p1_supply = player1._supply()
		p2_supply = player2._supply()
		player1._combat_end()
		player2._combat_end()
		if player1._is_recovery() and player2._is_recovery():
			round_count += 1
			_start_effect()
		else:
			phase = IGameServer.Phase.RECOVERY
			recovery_count = 0

	return IGameServer.CombatData.new(current_round_count,phase,
			IGameServer.CombatData.PlayerData.new(p1_hand,index1,
					player1._before_effect_log_temporary().duplicate(),
					p1_comparison,
					player1._moment_effect_log_temporary().duplicate(),
					p1_result,
					player1._after_effect_log_temporary().duplicate(),
					player1._end_effect_log_temporary().duplicate(),
					p1_supply,
					player1._start_effect_log_temporary().duplicate(),
					player1._get_damage(),player1._get_life(),0),
			IGameServer.CombatData.PlayerData.new(p2_hand,index2,
					player2._before_effect_log_temporary().duplicate(),
					p2_comparison,
					player2._moment_effect_log_temporary().duplicate(),
					p2_result,
					player2._after_effect_log_temporary().duplicate(),
					player2._end_effect_log_temporary().duplicate(),
					p2_supply,
					player2._start_effect_log_temporary().duplicate(),
					player2._get_damage(),player2._get_life(),0))


func recover(index1:int,index2:int) -> IGameServer.RecoveryData:
	var current_round_count := round_count
	recovery_count += 1

	var p1_hand := player1._get_hand().duplicate()
	var p2_hand := player2._get_hand().duplicate()
	
	player1._start_effect_log_temporary().clear()
	player2._start_effect_log_temporary().clear()

	var p1_result : IGameServer.EffectLog
	if player1._is_recovery():
		index1 = -1
		p1_result = IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
	else:
		index1 = mini(maxi(0, index1), p1_hand.size() - 1);
		p1_result = player1._recover(index1)
	var p2_result : IGameServer.EffectLog
	if player2._is_recovery():
		index2 = -1
		p2_result = IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,[])
	else:
		index2 = mini(maxi(0, index2), p2_hand.size() - 1);
		p2_result = player2._recover(index2)
	
	if player1._is_recovery() and player2._is_recovery():
		round_count += 1
		phase = IGameServer.Phase.COMBAT
		_start_effect()
	elif (((not player1._is_recovery()) and
			player1._get_hand().size() + player1._get_stock_count() <= 1)
			or
			((not player2._is_recovery()) and
			player2._get_hand().size() + player2._get_stock_count() <= 1)):
		phase = IGameServer.Phase.GAME_END

	return IGameServer.RecoveryData.new(current_round_count,phase,recovery_count,
			IGameServer.RecoveryData.PlayerData.new(p1_hand,index1,
			player1._start_effect_log_temporary().duplicate(),p1_result,
			player1._get_damage(),player1._get_life(),0),
			IGameServer.RecoveryData.PlayerData.new(p2_hand,index2,
			player2._start_effect_log_temporary().duplicate(),p2_result,
			player2._get_damage(),player2._get_life(),0))


func _before_effect():
	var effect_order : Array[EffectOrder] = []
	for s in player1._get_states():
		for p in s._before_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._before_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	
	var p1_color := player1._get_playing_card().data.color
	var p2_color := player2._get_playing_card().data.color
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for s in player1._get_playing_card().skills:
		if s._get_skill().test_condition(p2_color,p1_link_color):
			for p in s._before_priority():
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_playing_card().skills:
		if s._get_skill().test_condition(p1_color,p2_link_color):
			for p in s._before_priority():
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	
	for s in effect_order:
		s.myself._before_effect_log_temporary().append(
				s.effect._before_effect(s.priority,s.myself,s.rival))


func _moment_effect():
	var effect_order : Array[EffectOrder] = []
	for s in player1._get_states():
		for p in s._moment_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._moment_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	
	var p1_color := player1._get_playing_card().data.color
	var p2_color := player2._get_playing_card().data.color
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for s in player1._get_playing_card().skills:
		if s._get_skill().test_condition(p2_color,p1_link_color):
			for p in s._moment_priority():
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_playing_card().skills:
		if s._get_skill().test_condition(p1_color,p2_link_color):
			for p in s._moment_priority():
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.myself._moment_effect_log_temporary().append(
				s.effect._moment_effect(s.priority,s.myself,s.rival))


func _after_effect():
	var effect_order : Array[EffectOrder] = []
	for s in player1._get_states():
		for p in s._after_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._after_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))

	var p1_color := player1._get_playing_card().data.color
	var p2_color := player2._get_playing_card().data.color
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for s in player1._get_playing_card().skills:
		if s._get_skill().test_condition(p2_color,p1_link_color):
			for p in s._after_priority():
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_playing_card().skills:
		if s._get_skill().test_condition(p1_color,p2_link_color):
			for p in s._after_priority():
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.myself._after_effect_log_temporary().append(
				s.effect._after_effect(s.priority,s.myself,s.rival))


func _end_effect():
	var effect_order : Array[EffectOrder] = []
	for s in player1._get_states():
		for p in s._end_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._end_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	
	var p1_color := player1._get_playing_card().data.color
	var p2_color := player2._get_playing_card().data.color
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for s in player1._get_playing_card().skills:
		if s._get_skill().test_condition(p2_color,p1_link_color):
			for p in s._end_priority():
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_playing_card().skills:
		if s._get_skill().test_condition(p1_color,p2_link_color):
			for p in s._end_priority():
				effect_order.append(EffectOrder.new(s,p,player2,player1,))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.myself._end_effect_log_temporary().append(
				s.effect._end_effect(s.priority,s.myself,s.rival))


func _start_effect():
	var effect_order : Array[EffectOrder] = []
	for s in player1._get_states():
		for p in s._start_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._start_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.myself._start_effect_log_temporary().append(
				s.effect._start_effect(s.priority,s.myself,s.rival))
