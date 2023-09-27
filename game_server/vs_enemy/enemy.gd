
extends StandardPlayer

class_name EnemyPlayer


func _init(enemy_data : EnemyData):
	_card_factory = enemy_data.factory
	var pile := []
	for i in range(enemy_data.deck_list.size()):
		var c := _card_factory._create(i,enemy_data.deck_list[i])
		_deck_list.append(c);
		pile.append(i);
	_life = enemy_data.hp
	if enemy_data.shuffle:
		pile.shuffle()
	else:
		pile.reverse()
	_stock = PackedInt32Array(pile)
	for _i in range(enemy_data.hand):
		_draw_card()

	
func _combat_start(i : int) -> void:
	_select_card = _hand[i]
	_hand.remove_at(i)
#	_life -= _deck_list[_select_card].level
	return

func _damage_is_fatal() -> bool:
	var total_damage := _damage - _get_current_block()
	_damage = maxi(total_damage,0)
	if _life <= _damage:
		return true
	if _hand.is_empty() and _stock.is_empty():
		return true
	return false

func _combat_end() -> void:
	_played.push_back(_select_card)
	_select_card = -1

func _supply() -> IGameServer.EffectLog:
	var fragments : Array[IGameServer.EffectFragment] = []
	fragments.append(_draw_card())
	return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,fragments)

func _recover(_index : int) -> IGameServer.EffectLog:
	var fragments : Array[IGameServer.EffectFragment] = []
	_life -= _damage
	fragments.append(_recover_life(_damage,false))
	_damage = 0
	return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,fragments)
	

func _discard_card(card : int,opponent : bool = false) -> IGameServer.EffectFragment:
	var index := _hand.find(card)
	if index >= 0:
		_hand.remove_at(index)
#		_life -= _deck_list[card].level
		_discard.append(card)
		var passive : Array[IGameServer.PassiveLog] = []
		passive_discarded.emit(card,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
		return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD_CARD,opponent,card,passive)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD_CARD,opponent,-1,[])
	

#	CREATE_CARD,	# [card_id : int,opponent_source : bool,data_id : int,position : int,changes : Dictionary]
func _create_card(factory : ICardFactory , data_id:int,position : int,changes : Dictionary,
		opponent : bool = false) -> IGameServer.EffectFragment:
	var index := _deck_list.size()
	var card := factory._create(index,data_id)
	for k in changes:
		match k:
			"power":
				card.power = changes["power"]
			"hit":
				card.hit = changes["hit"]
			"block":
				card.block = changes["block"]
			"level":
				card.level = changes["level"]
	
	_deck_list.append(card)
	if position < 0:
		_stock.insert(_stock.size() + 1 + position,card.id_in_deck)
	else:
		_stock.insert(position,card.id_in_deck)
#	_life += card.level
	
	var passive : Array[IGameServer.PassiveLog] = []
	passive_card_created.emit(index,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
	var opponent_source := factory != _card_factory
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CREATE_CARD,
			opponent,[index,opponent_source,data_id,position,changes],passive)
