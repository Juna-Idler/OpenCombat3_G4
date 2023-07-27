
extends MechanicsData.IPlayer


class_name OfflinePlayer


var _card_factory : MechanicsData.ICardFactory = null

var _deck_list : Array[MechanicsData.Card] = []

var _hand : PackedInt32Array = []
var _stock : PackedInt32Array = []
var _played : PackedInt32Array = []
var _discard : PackedInt32Array = []
var _life : int = 0

var _states : Dictionary = {}
var _states_counter : int = 0

var _damage : int = 0
var _select_card : int = -1
var _initiative : bool = false

var _start_effect_log : Array[IGameServer.EffectLog] = []
var _before_effect_log : Array[IGameServer.EffectLog] = []
var _moment_effect_log : Array[IGameServer.EffectLog] = []
var _after_effect_log : Array[IGameServer.EffectLog] = []
var _end_effect_log : Array[IGameServer.EffectLog] = []


func _init(factory : MechanicsData.ICardFactory, deck : PackedInt32Array,
		hand_count : int,shuffle : bool = true) -> void:
	_card_factory = factory
	var pile := []
	for i in range(deck.size()):
		var c := _card_factory._create(i,deck[i])
		_deck_list.append(c);
		pile.append(i);
		_life += c.data.level
	if shuffle:
		pile.shuffle()
	_stock = PackedInt32Array(pile)
	for _i in range(hand_count):
		_draw_card()

func _get_card_factory() -> ICardFactory:
	return _card_factory
	
func _get_deck_list() -> Array[Card]:
	return _deck_list
func _get_hand() -> PackedInt32Array:
	return _hand
func _get_played() -> PackedInt32Array:
	return _played
func _get_discard() -> PackedInt32Array:
	return _discard

func _get_stock_count() -> int:
	return _stock.size()

func _get_life() -> int:
	return _life

func _get_states() -> Dictionary:
	return _states


func _get_damage() -> int:
	return _damage


	
func _combat_start(i : int) -> void:
	_select_card = _hand[i]
	_hand.remove_at(i)
	_life -= _deck_list[_select_card].data.level
	return

func _get_playing_card_id() -> int:
	return _select_card
func _get_playing_card() -> Card:
	return _deck_list[_select_card]
func _get_link_color() -> CatalogData.CardColors:
	return CatalogData.CardColors.NOCOLOR if _played.is_empty() else _deck_list[_played[-1]].data.color

func _get_current_power() -> int:
	return _deck_list[_select_card].get_current_power()
func _get_current_hit() -> int:
	return _deck_list[_select_card].get_current_hit()
func _get_current_block() -> int:
	return _deck_list[_select_card].get_current_block()

func _has_initiative() -> bool:
	return _initiative

func _get_card_stats(_id:int) -> PackedInt32Array:
	var card := _deck_list[_id]
	return [card.power,card.hit,card.block]

func _damage_is_fatal() -> bool:
	var total_damage := _damage - _get_current_block()
	_damage = maxi(total_damage,0)
	if _life <= _damage:
		return true
	return false

func _combat_end() -> void:
	_played.push_back(_select_card)
	_select_card = -1

func _supply() -> Array[IGameServer.EffectFragment]:
	if _damage > 0:
		return [_draw_card()]
	return []

func _recover(index : int) -> Array[IGameServer.EffectFragment]:
	var fragments : Array[IGameServer.EffectFragment] = []
	_select_card = _hand[index]
	fragments.append(_discard_card(index))
	_damage -= _deck_list[_select_card].data.level
	if _damage <= 0:
		_damage = 0
		return fragments
	fragments.append(_draw_card())
	return fragments

	
func _is_recovery() -> bool:
	return _damage == 0

func _change_order(new_hand : PackedInt32Array) -> void:
	if new_hand.size() != _hand.size():
		return
	for i in _hand:
		if not new_hand.has(i):
			return
	for i in _hand.size():
		_hand[i] = new_hand[i]
	return


func _start_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return _start_effect_log
func _before_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return _before_effect_log
func _moment_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return _moment_effect_log
func _after_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return _after_effect_log
func _end_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return _end_effect_log


func _add_damage(damage: int,opponent : bool = true) -> IGameServer.EffectFragment:
	var block := maxi(_get_current_block() - _damage,0)
	_damage += damage
	var passive : Array[IGameServer.PassiveLog] = []
	passive_damaged.emit(damage,block,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DAMAGE,
			opponent,[damage,block],passive)
	
func _set_initiative(initiative : bool,opponent : bool = false) -> IGameServer.EffectFragment:
	var passive : Array[IGameServer.PassiveLog] = []
	passive_initiative_changed.emit(initiative,_initiative,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	_initiative = initiative
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.INITIATIVE,
			opponent,_initiative,passive)
	
#	CHANGE_STATS,	# [card_id : int,power : int,hit : int,block : int]
func _change_card_stats(id : int,stats : PackedInt32Array,opponent : bool = false) -> IGameServer.EffectFragment:
	var old := _get_card_stats(id)
	var passive : Array[IGameServer.PassiveLog] = []
	passive_card_stats_changed.emit(id,
			stats[0],stats[1],stats[2],
			old[0],old[1],old[2],
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	var card := _deck_list[id]
	card.power = stats[0]
	card.hit = stats[1]
	card.block = stats[2]
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CHANGE_STATS,
			opponent,[id,card.power,card.hit,card.block],passive)


func _draw_card(opponent : bool = false) -> IGameServer.EffectFragment:
	if _stock.is_empty():
		return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DRAW_CARD,opponent,-1,[])
	var id := _stock[-1]
	_stock.resize(_stock.size() - 1)
	_hand.append(id)
	var passive : Array[IGameServer.PassiveLog] = []
	passive_drawn.emit(id,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DRAW_CARD,opponent,id,passive)


func _discard_card(card : int,opponent : bool = false) -> IGameServer.EffectFragment:
	var index := _hand.find(card)
	if index >= 0:
		_hand.remove_at(index)
		_life -= _deck_list[card].data.level
		_discard.append(card)
		var passive : Array[IGameServer.PassiveLog] = []
		passive_discarded.emit(card,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
		return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD,opponent,card,passive)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD,opponent,-1,[])
	
func _bounce_card(card : int,position : int,opponent : bool = false) -> IGameServer.EffectFragment:
	var index := _hand.find(card)
	if index >= 0:
		_hand.remove_at(index)
		if position < 0:
			position = maxi(_stock.size() + 1 - position,0)
		else:
			position = mini(position,_stock.size())
		_stock.insert(position,card)
		var passive : Array[IGameServer.PassiveLog] = []
		passive_discarded.emit(card,position,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
		return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.BOUNCE_CARD,opponent,[card,position],passive)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.BOUNCE_CARD,opponent,[-1,0],[])


func _create_state(factory : ICardFactory,data_id : int,param : Array,rival : MechanicsData.IPlayer,opponent : bool = false) -> IGameServer.EffectFragment:
	_states_counter += 1
	var state := factory._create_state(_states_counter,data_id,param,self,rival)
	_states[state] = _states_counter
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CREATE_STATE,
			opponent,[_states_counter,opponent,data_id,param],[])

func _update_state(state : IState,param:Array,opponent : bool = false) -> IGameServer.EffectFragment:
	var id : int = _states[state]
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.UPDATE_STATE,
			opponent,[id,param],[])

#	DELETE_STATE,	# state_id : int
func _delete_state(state : IState,opponent : bool = false) -> IGameServer.EffectFragment:
	var id : int = _states[state]
	state._term()
	_states.erase(state)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DELETE_STATE,
			opponent,id,[])
	

#	CREATE_CARD,	# [card_id : int,opponent_source : bool,data_id : int,changes : Dictionary]
func _create_card(factory : ICardFactory , data_id:int,changes : Dictionary,opponent : bool = false) -> IGameServer.EffectFragment:
	var index := _deck_list.size()
	var card := factory._create(index,data_id)
	_deck_list.append(card)
	
	var passive : Array[IGameServer.PassiveLog] = []
	passive_card_created.emit(index,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CREATE_CARD,
			opponent,[index,opponent,data_id,changes],passive)
