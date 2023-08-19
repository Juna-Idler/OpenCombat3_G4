
extends MechanicsData.IPlayer


class_name ReplayPlayer

var _card_factory : MechanicsData.ICardFactory = null

var _deck_list : Array[MechanicsData.Card] = []

var _hand : PackedInt32Array = []
var _stock_count : int
var _played : PackedInt32Array = []
var _discard : PackedInt32Array = []
var _life : int = 0

var _enchants : Dictionary = {}
var _enchants_counter : int = 0

var _damage : int = 0
var _select_card : int = -1
var _initiative : bool = false



var _rival_side : bool

#var update_data : Array
#var step_data : IGameServer.UpdateData.PlayerData
#var step_draw : Array
#var first_data : IGameServer.UpdateData.PlayerData

func _init(match_log :MatchLog,rival : bool,factory : MechanicsData.ICardFactory) -> void:
	_rival_side = rival
	var deck = match_log.primary_data.rival_deck_list if _rival_side else match_log.primary_data.my_deck_list
	for i in range(deck.size()):
		var c := _card_factory._create(i,deck[i])
		_deck_list.append(c);
		_life += c.data.level

	var fd = match_log.first_data.rival if _rival_side else match_log.first_data.myself
#	first_data = IGameServer.UpdateData.PlayerData.new(fd.hand,0,[],[],0,fd.life,
#			match_log.primary_data.match_regulation.thinking_time * 1000)
	_hand = fd.hand.duplicate()
	_stock_count = _deck_list.size() - _hand.size()
#	update_data = match_log.update_data
	set_step(0)


func set_step(step : int):
	if step == 0:
		step_data = first_data
		return
	var data = (update_data[step-1] as MatchLog.TimedUpdateData).data
	step_data = data.rival if rival_side else data.myself
	step_draw = Array(step_data.draw)


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
	return _stock_count

func _get_life() -> int:
	return _life

func _get_enchants() -> Dictionary:
	return _enchants

func _get_damage() -> int:
	return _damage


func _combat_start(i : int) -> void:
	_select_card = _hand[i]
	_hand.remove_at(i)
	_life -= _deck_list[_select_card].level
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
#	var total_damage := _damage - _get_current_block()
#	_damage = maxi(total_damage,0)
#	if _life <= _damage:
#		return true
	return false

func _combat_end() -> void:
	_played.push_back(_select_card)
	_select_card = -1
	

func _supply() -> IGameServer.EffectLog:
	var fragments : Array[IGameServer.EffectFragment] = []
	fragments.append(_draw_card())
	if _damage > 0:
		fragments.append(_draw_card())
	return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,fragments)

func _recover(index : int) -> IGameServer.EffectLog:
	var fragments : Array[IGameServer.EffectFragment] = []
	_select_card = _hand[index]
	fragments.append(_discard_card(_select_card))
	fragments.append(_recover_life(_deck_list[_select_card].level,false))
	if _damage <= 0:
		_damage = 0
		return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,fragments)
	fragments.append(_draw_card())
	return IGameServer.EffectLog.new(IGameServer.EffectSourceType.SYSTEM_PROCESS,0,0,fragments)

	
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
	return []
func _before_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return []
func _moment_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return []
func _after_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return []
func _end_effect_log_temporary() -> Array[IGameServer.EffectLog]:
	return []




func _add_damage(damage: int,opponent : bool = true) -> IGameServer.EffectFragment:
	var block := maxi(_get_current_block() - _damage,0)
	_damage += damage
	if damage > block:
		damage -= block
	else:
		block = damage
		damage = 0
	var passive : Array[IGameServer.PassiveLog] = []
	passive_damaged.emit(damage,block,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DAMAGE,
			opponent,[damage,block],passive)

func _recover_life(recovery_point : int,opponent : bool) -> IGameServer.EffectFragment:
	if _damage < recovery_point:
		recovery_point = _damage
	var passive : Array[IGameServer.PassiveLog] = []
	passive_recovered.emit(recovery_point,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	_damage -= recovery_point
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.RECOVERY,
			opponent,recovery_point,passive)

func _set_initiative(initiative : bool,opponent : bool = false) -> IGameServer.EffectFragment:
	var passive : Array[IGameServer.PassiveLog] = []
	passive_initiative_changed.emit(initiative,_initiative,
			func (plog : IGameServer.PassiveLog): passive.append(plog))
	_initiative = initiative
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.INITIATIVE,
			opponent,_initiative,passive)

func _change_combat_card_stats(stats : PackedInt32Array,opponent : bool = false) -> IGameServer.EffectFragment:
	var id := _get_playing_card_id()
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
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.COMBAT_STATS,
			opponent,[card.power,card.hit,card.block],passive)
	
#	CARD_STATS,	# [card_id : int,power : int,hit : int,block : int]
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
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CARD_STATS,
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
		_life -= _deck_list[card].level
		_discard.append(card)
		var passive : Array[IGameServer.PassiveLog] = []
		passive_discarded.emit(card,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
		return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD_CARD,opponent,card,passive)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DISCARD_CARD,opponent,-1,[])
	
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


func _create_enchant(factory : ICardFactory,data_id : int,param : Array,rival : MechanicsData.IPlayer,opponent : bool = false) -> IGameServer.EffectFragment:
	_enchants_counter += 1
	var enchant := factory._create_enchant(_enchants_counter,data_id,param,self,rival)
	_enchants[enchant] = _enchants_counter
	var opponent_source := factory != _card_factory
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CREATE_ENCHANTMENT,
			opponent,[_enchants_counter,opponent_source,data_id,param],[])

func _update_enchant(enchant : IEnchantment,opponent : bool = false) -> IGameServer.EffectFragment:
	var id : int = _enchants[enchant]
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.UPDATE_ENCHANTMENT,
			opponent,[id,enchant._get_parameter()],[])

#	DELETE_ENCHANTMENT,	# enchant_id : int
func _delete_enchant(enchant : IEnchantment,expired : bool = true,opponent : bool = false) -> IGameServer.EffectFragment:
	var id : int = _enchants[enchant]
	enchant._term()
	_enchants.erase(enchant)
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.DELETE_ENCHANTMENT,
			opponent,[id,expired],[])
	

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
	_life += card.level
	
	var passive : Array[IGameServer.PassiveLog] = []
	passive_card_created.emit(index,
				func (plog : IGameServer.PassiveLog): passive.append(plog))
	var opponent_source := factory != _card_factory
	return IGameServer.EffectFragment.new(IGameServer.EffectFragmentType.CREATE_CARD,
			opponent,[index,opponent_source,data_id,position,changes],passive)


