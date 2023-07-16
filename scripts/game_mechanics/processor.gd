
class_name GameProcessor

enum  Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}

var round_count : int
var phase : int
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


func standby(p1 : MechanicsData.IPlayer,p2 : MechanicsData.IPlayer):
	round_count = 1
	phase = Phase.COMBAT;
	player1 = p1
	player2 = p2


func reorder_hand1(hand:PackedInt32Array):
	player1._change_order(hand)

func reorder_hand2(hand:PackedInt32Array):
	player2._change_order(hand)


func combat(index1 : int,index2 : int) -> void:
	if phase != Phase.COMBAT:
		return
	index1 = mini(maxi(0, index1), player1._get_hand().size() - 1);
	index2 = mini(maxi(0, index2), player2._get_hand().size() - 1);


	player1._combat_start(index1)
	player2._combat_start(index2)

	_before_process()

	var situation := player1._get_current_power() - player2._get_current_power();
	if situation > 0:
		player1._set_initiative(true)
		player2._set_initiative(false)
	elif situation < 0:
		player1._set_initiative(false)
		player2._set_initiative(true)
	else:
		player1._set_initiative(false)
		player2._set_initiative(false)

	_engaged_process()

	if (player1._has_initiative()):
		player2._add_damage(player1._get_current_hit())
	if (player2._has_initiative()):
		player1._add_damage(player2._get_current_hit())

	_after_process()

	var p1fatal := player1._damage_is_fatal()
	var p2fatal := player2._damage_is_fatal()

	if p1fatal or p2fatal:
		phase = Phase.GAME_END
		return

	_end_process()
	player1._supply()
	player2._supply()
	
	player1._combat_end()
	player2._combat_end()


	if player1._is_recovery() and player2._is_recovery():
		round_count += 1
#		_start_process()
		
	else:
		phase = Phase.RECOVERY

func recover(index1:int,index2:int):
	if index1 < 0:
		player1._no_recover()
	else:
		player1._recover(index1)
	if index2 < 0:
		player2._no_recover()
	else:
		player2._recover(index2)
		
	if player1._is_recovery() and player2._is_recovery():
		round_count += 1
		phase = Phase.COMBAT
	elif (((not player1._is_recovery()) and
			player1._get_hand().size() + player1._get_stock_count() <= 1)
			or
			((not player2._is_recovery()) and
			player2._get_hand().size() + player2._get_stock_count() <= 1)):
		phase = Phase.GAME_END

func reset_select():
	player1._reset_select()
	player2._reset_select()



func _before_process():
	var effect_order := []
	for s in player1._get_states():
		for p in s._before_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_states():
		for p in s._before_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for s in player1._get_playing_card().skills:
		if s._get_skill().test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = s._before_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for s in player2._get_playing_card().skills:
		if s._get_skill().test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = s._before_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.effect._process_before(s.index,s.priority,s.myself,s.rival)


func _engaged_process():
	var effect_order := []
	for i in player1._get_states().size():
		var s := player1._get_states()[i] as MechanicsData.IState
		for p in s._engaged_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_states().size():
		var s := player2._get_states()[i] as MechanicsData.IState
		for p in s._engaged_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))

	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = s._engaged_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = s._engaged_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.effect._process_engaged(s.index,s.priority,s.myself,s.rival)


func _after_process():
	var effect_order := []
	for i in player1._get_states().size():
		var s := player1._get_states()[i] as MechanicsData.IState
		for p in s._after_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_states().size():
		var s := player2._get_states()[i] as MechanicsData.IState
		for p in s._after_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))

	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = s._after_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = s._after_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player2,player1))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.effect._process_after(s.index,s.priority,s.situation,s.myself,s.rival)


func _end_process():
	var effect_order := []
	for i in player1._get_states().size():
		var s := player1._get_states()[i] as MechanicsData.IState
		for p in s._end_priority():
			effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_states().size():
		var s := player2._get_states()[i] as MechanicsData.IState
		for p in s._end_priority():
			effect_order.append(EffectOrder.new(s,p,player2,player1))
	
	var p1_link_color := player1._get_link_color()
	var p2_link_color := player2._get_link_color()
	for i in player1._get_playing_card().data.skills.size():
		var s := player1._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player2._get_playing_card().data.color,p1_link_color):
			var priority = s._end_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player1,player2))
	for i in player2._get_playing_card().data.skills.size():
		var s := player2._get_playing_card().skills[i] as MechanicsData.ISkill
		if s._get_skill().test_condition(player1._get_playing_card().data.color,p2_link_color):
			var priority = s._end_priority()
			for p in priority:
				effect_order.append(EffectOrder.new(s,p,player2,player1,))
	effect_order.sort_custom(EffectOrder.custom_compare)
	for s in effect_order:
		s.effect._process_end(s.index,s.priority,s.situation,s.myself,s.rival)

