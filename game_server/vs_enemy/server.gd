extends IGameServer

class_name VsEnemyServer

const COMBAT_RESULT_DELAY = -1
const COMBAT_SKILL_DELAY = -1
const RECOVER_RESULT_DELAY = -1


var _processor := GameProcessor.new()

var _player : StandardPlayer
var _enemy : EnemyPlayer

var _player_name:String

var _player_catalog : I_CardCatalog

var _enemy_data : EnemyData

var non_playable_recovery_phase : bool = false


func _init():
	pass

func initialize(name:String,deck:PackedInt32Array,hand : int,shuffle : bool,
		card_catalog : I_CardCatalog,card_factory : MechanicsData.ICardFactory,
		enemy : EnemyData):
	_player_name = name;
	
	_player_catalog = card_catalog
	_enemy_data = enemy
	
#	var factory := PlayerCardFactory.new(card_catalog)
	
	_player = StandardPlayer.new(card_factory,deck,hand,shuffle)
	_enemy = EnemyPlayer.new(enemy)
	

func _get_primary_data() -> PrimaryData:
	var my_deck_list : PackedInt32Array = []
	for c in _player._get_deck_list():
		my_deck_list.append(c.data.id)
	var r_deck_list  : PackedInt32Array = []
	for c in _enemy._get_deck_list():
		r_deck_list.append(c.data.id)
	return PrimaryData.new(_player_name,my_deck_list,_player_catalog._get_catalog_name(),
			_enemy_data.name,r_deck_list,_enemy_data.catalog._get_catalog_name(),"","")

func _send_ready():

	var first := _processor.standby(_player,_enemy)
	first.myself.time = -1

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


