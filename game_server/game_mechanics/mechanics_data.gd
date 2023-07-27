
class_name MechanicsData



class Card:
	var data : CatalogData.CardData = null
	var id_in_deck : int = 0
	
	var power : int
	var hit : int
	var block : int
	var level : int
	var color : CatalogData.CardColors
	var skills : Array[ISkill]

	func _init(iid : int,cd : CatalogData.CardData,s : Array[ISkill]):
		data = cd
		id_in_deck = iid
		skills = s
		power = cd.power
		hit = cd.hit
		block = cd.block
		level = cd.level
		color = cd.color

	func get_current_power() -> int:
		return maxi(power,0)
	func get_current_hit() -> int:
		return maxi(hit,0)
	func get_current_block() -> int:
		return maxi(block,0)


class ICardFactory:
	func _create(_iid : int,_data_id : int) -> Card:
		return null
	func _create_skill(_skill : CatalogData.CardSkill) -> ISkill:
		return null
	func _create_state(_state_id : int,_data_id : int,_param : Array,_attached : IPlayer,_opponent : IPlayer) -> IState:
		return null


class IPlayer:
	
#	func _add_log(log : IGameServer.PassiveLog) -> void:
#		return
	signal passive_damaged(damage:int,block:int,_add_log : Callable)
	signal passive_initiative_changed(new_init:bool,old_init:bool,_add_log : Callable)
	signal passive_card_stats_changed(card : int,
			new_power : int,new_hit : int,new_block : int,
			old_power : int,old_hit : int,old_block : int,
			_add_log : Callable)
	
	signal passive_drawn(card:int,_add_log : Callable)
	signal passive_discarded(card:int,_add_log : Callable)
	signal passive_bounced(card:int,position:int,_add_log : Callable)
	
	signal passive_card_created(card:int,_add_log : Callable)


	
	func _get_card_factory() -> ICardFactory:
		return null
		
	
	func _get_deck_list() -> Array[Card]:
		return []
	func _get_hand() -> PackedInt32Array:
		return PackedInt32Array()
	func _get_played() -> PackedInt32Array:
		return PackedInt32Array()
	func _get_discard() -> PackedInt32Array:
		return PackedInt32Array()

	func _get_stock_count() -> int:
		return 0

	func _get_life() -> int:
		return 0

	func _get_states() -> Dictionary:
		return {}


	func _get_damage() -> int:
		return 0


	func _combat_start(_index : int) -> void:
		return

	func _get_playing_card_id() -> int:
		return -1

	func _get_playing_card() -> Card:
		return null
	
	func _get_link_color() -> CatalogData.CardColors:
		return CatalogData.CardColors.NOCOLOR


	func _get_current_power() -> int:
		return 0
	func _get_current_hit() -> int:
		return 0
	func _get_current_block() -> int:
		return 0

	func _has_initiative() -> bool:
		return false

	func _get_card_stats(_id:int) -> PackedInt32Array:
		return [0,0,0]


	func _damage_is_fatal() -> bool:
		return false

	func _combat_end() -> void:
		return
	
	#ダメージを受けたときの回復前ドロー挙動
	func _supply() -> Array[IGameServer.EffectFragment]:
		return []

	#ダメージを受けたときの回復挙動
	func _recover(_index : int) -> Array[IGameServer.EffectFragment]:
		return []

		
	func _is_recovery() -> bool:
		return true


	func _change_order(_new_hand : PackedInt32Array) -> void:
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

#	IGameServer.EffectFragment

#	DAMAGE,			# [damage : int,block : int]
	func _add_damage(_damage: int,_opponent : bool = true) -> IGameServer.EffectFragment:
		return null
		
#	INITIATIVE,		# initiative : bool
	func _set_initiative(_initiative : bool,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
		
#	CHANGE_STATS,	# [card_id : int,power : int,hit : int,block : int]
	func _change_card_stats(_card : int,_stats : PackedInt32Array,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
	
#	DRAW_CARD,		# card_id : int
	func _draw_card(_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
		
#	DISCARD,		# card_id : int
	func _discard_card(_card : int,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
		
#	BOUNCE_CARD,	# [card_id : int,position : int]
	func _bounce_card(_card : int,_position : int,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null


#	CREATE_STATE,	# [state_id : int,opponent_source : bool,data_id : int,param : Array]
	func _create_state(_factory : ICardFactory,_data_id : int,_param : Array,_rival : IPlayer,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
	
#	UPDATE_STATE,	# [state_id : int,param : Array]
	func _update_state(_state : IState,_param:Array,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null
	
#	DELETE_STATE,	# state_id : int
	func _delete_state(_state : IState,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null


#	CREATE_CARD,	# [card_id : int,opponent_source : bool,data_id : int,changes : Dictionary]
	func _create_card(_factory : ICardFactory , _data_id:int,_changes : Dictionary,_opponent : bool = false) -> IGameServer.EffectFragment:
		return null



class IEffect:

	func _before_priority() -> Array:
		return []
	func _before_effect(_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		return null
		
	func _moment_priority() -> Array:
		return []
	func _moment_effect(_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		return null
		
	func _after_priority() -> Array:
		return []
	func _after_effect(_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		return null
		
	func _end_priority() -> Array:
		return []
	func _end_effect(_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		return null



class ISkill extends IEffect:
	func _get_skill() -> CatalogData.CardSkill:
		return null

class BasicSkill extends ISkill:
	var _skill : CatalogData.CardSkill
	func _init(skill : CatalogData.CardSkill):
		_skill = skill
		
	func _get_skill() -> CatalogData.CardSkill:
		return _skill


class IState extends IEffect:
	func _get_data_id() -> int:
		return -1
	
	func _term() -> void:
		return
	
	func _start_priority() -> Array:
		return []
	func _start_effect(_priority : int,
			_myself : IPlayer,_rival : IPlayer) -> IGameServer.EffectLog:
		return null
		

class BasicState extends IState:
	var _match_id : int
	
	func _init(mid : int):
		_match_id = mid
		
	func _get_match_id() -> int:
		return _match_id

