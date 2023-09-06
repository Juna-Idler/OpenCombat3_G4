extends IGameServer

class_name StoryServer

const COMBAT_RESULT_DELAY = -1
const COMBAT_SKILL_DELAY = -1
const RECOVER_RESULT_DELAY = -1


var _processor := GameProcessor.new()

var _player : StandardPlayer

var _enemy : EnemyPlayer

var _player_name:String

var deck_regulation : RegulationData.DeckRegulation
var match_regulation : RegulationData.MatchRegulation


var non_playable_recovery_phase : bool = false


func _init():
	pass

func initialize(name:String,deck:PackedInt32Array,card_catalog : CardCatalog,
		enemy,cpu_deck:PackedInt32Array,cpu_card_catalog : CardCatalog,
		d_regulation :RegulationData.DeckRegulation,
		m_regulation :RegulationData.MatchRegulation):
	_player_name = name;

	deck_regulation = d_regulation
	match_regulation = m_regulation
	
	var factory := PlayerCardFactory.new(card_catalog)
	var cpu_factory := PlayerCardFactory.new(cpu_card_catalog)
	
	_player = StandardPlayer.new(factory,deck,m_regulation.hand_count,true)
	_enemy = EnemyPlayer.new(cpu_factory,cpu_deck,m_regulation.hand_count,true)
	

func _get_primary_data() -> PrimaryData:
	var my_deck_list : PackedInt32Array = []
	for c in _player._get_deck_list():
		my_deck_list.append(c.data.id)
	var r_deck_list  : PackedInt32Array = []
	for c in _enemy._get_deck_list():
		r_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,
			"enemy",r_deck_list,
			deck_regulation,match_regulation)

func _send_ready():

	var first := _processor.standby(_player,_enemy)
	first.myself.time = match_regulation.thinking_time

	recieved_first_data.emit(first)



func _send_combat_select(round_count:int,index:int,hands_order:PackedInt32Array = []):

# warning-ignore:integer_division
	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.COMBAT:
		return
	if not hands_order.is_empty():
		_processor.reorder_hand1(hands_order)

	var combat_result := _processor.combat(index,0)
	
	combat_result.myself.time = -1
	combat_result.rival.time = -1

	if _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			if _processor.player1._is_recovery():
				non_playable_recovery_phase = true
	
	recieved_combat_result.emit(combat_result)


static func count_effect(pd : IGameServer.CombatData.PlayerData) -> int:
	return pd.before.size() + pd.moment.size() + pd.after.size() + pd.end.size() + pd.start.size()


static func create_commander_player(player : MechanicsData.IPlayer) -> ICpuCommander.Player:
	return ICpuCommander.Player.new(player._get_hand(),player._get_played(),
			player._get_discard(),player._get_stock_count(),player._get_life(),
			player._get_enchants())
	


func _send_recovery_select(round_count:int,index:int,hands_order:PackedInt32Array = []):
	
	var index2 = 0 if not _processor.player2._is_recovery() else -1

	if _processor.round_count != round_count:
		return
	if _processor.phase != Phase.RECOVERY:
		return
	if not hands_order.is_empty():
		_processor.reorder_hand1(hands_order)

	var recovery_result := _processor.recover(index,index2)
	
	recovery_result.myself.time = -1
	recovery_result.rival.time = -1

	non_playable_recovery_phase = false
	if _processor.phase == Phase.RECOVERY:
		if not _processor.player2._is_recovery():
			if _processor.player1._is_recovery():
				non_playable_recovery_phase = true
			
	recieved_recovery_result.emit(recovery_result)


func _send_surrender():
	recieved_end.emit("You surrender")


