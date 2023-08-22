

class_name IGameServer

# 何らかの事情でゲームを強制終了する時のシグナル
signal recieved_end(msg)
# func _on_GameServer_recieved_end(msg:String)->void:

# 1ターン目の情報を受信した時のシグナル
signal recieved_first_data(first_data : FirstData)
# func _on_GameServer_recieved_first_data(data:FirstData)->void:

signal recieved_combat_result(data : CombatData)
# func _on_GameServer_recieved_combat_result(data:CombatData)->void:
signal recieved_recovery_result(data : RecoveryData)
# func _on_GameServer_recieved_recovery_result(data:RecoveryData)->void:

signal recieved_complete_board(data : CompleteData)
# func _on_GameServer_recieved_complete_board(data:CompleteData)->void:


enum Phase {GAME_END = -1,COMBAT = 0,RECOVERY = 1}


class PrimaryData:
	var my_deck_list : PackedInt32Array
	var rival_deck_list : PackedInt32Array
	var my_name:String
	var rival_name:String
	var deck_regulation : RegulationData.DeckRegulation
	var match_regulation : RegulationData.MatchRegulation

	func _init(name:String,deck:PackedInt32Array,rname:String,rdeck:PackedInt32Array,
			dr:RegulationData.DeckRegulation,mr:RegulationData.MatchRegulation):
		my_deck_list = deck
		rival_deck_list = rdeck
		my_name = name
		rival_name = rname
		deck_regulation = dr
		match_regulation = mr

	func serialize() -> Dictionary:
		return {
			"md":my_deck_list,
			"rd":rival_deck_list,
			"mn":my_name,
			"rn":rival_name,
			"dr":deck_regulation.serialize(),
			"mr":match_regulation.serialize(),
		}
	static func deserialize(dic : Dictionary) -> PrimaryData:
		return PrimaryData.new(
			dic["mn"],dic["md"],dic["rn"],dic["rd"],
			RegulationData.DeckRegulation.deserialize(dic["dr"]),
			RegulationData.MatchRegulation.deserialize(dic["mr"]))


class FirstData:
	class PlayerData:
		var hand : PackedInt32Array # of int
		var life : int
		var time : float # thinking time
		var initial : Array[AbilityLog]	# デッキアビリティ
		var start : Array[EffectLog]	# 開始時効果
		
		func _init(h : PackedInt32Array,l : int,t : float,
				i : Array[AbilityLog],s : Array[EffectLog]):
			hand = h
			life = l
			time = t
			initial = i
			start = s
	
		func serialize() -> Dictionary:
			return {
				"h":hand,
				"l":life,
				"t":time,
				"ini":initial.map(func(v):return v.serialize()),
				"e0":start.map(func(v):return v.serialize()),
			}
		static func deserialize(dic : Dictionary) -> PlayerData:
			var ini : Array[AbilityLog] = []
			var e0 : Array[EffectLog] = []
			ini.assign(dic["ini"].map(func(v):return AbilityLog.deserialize(v)))
			e0.assign(dic["e0"].map(func(v):return EffectLog.deserialize(v)))
			return PlayerData.new(dic["h"],dic["l"],dic["t"],ini,e0)

	var myself:PlayerData
	var rival:PlayerData

	func _init(p1:PlayerData,p2:PlayerData):
		myself = p1
		rival = p2

	func serialize() -> Dictionary:
		return {
			"m":myself.serialize(),
			"r":rival.serialize(),
		}
	static func deserialize(dic : Dictionary) -> FirstData:
		return FirstData.new(PlayerData.deserialize(dic["m"]),
				PlayerData.deserialize(dic["r"]))


class CombatData:
	var round_count : int
	var next_phase : Phase

	class PlayerData:
		var hand : PackedInt32Array
		var select : int
		
		var before : Array[EffectLog]
		var comparison : EffectLog
		var moment : Array[EffectLog]
		var result : EffectLog
		var after : Array[EffectLog]
		var end : Array[EffectLog]
		var supply : EffectLog
		var start : Array[EffectLog]
		
		var damage:int
		var life:int
		var time:float # remain time
		
		func _init(h:PackedInt32Array,sel:int,
				e1: Array[EffectLog],c:EffectLog,
				e2: Array[EffectLog],r:EffectLog,
				e3: Array[EffectLog],e4: Array[EffectLog],sup:EffectLog,
				e0: Array[EffectLog],
				d:int,l:int,t:float):
			hand = h
			select = sel
			before = e1
			comparison = c
			moment = e2
			result = r
			after = e3
			end = e4
			supply = sup
			start = e0
			
			damage = d
			life = l
			time = t
			
		func serialize() -> Dictionary:
			return {
				"h":hand,
				"s":select,
				"e1":before.map(func(v):return v.serialize()),
				"com":comparison.serialize(),
				"e2":moment.map(func(v):return v.serialize()),
				"res":result.serialize(),
				"e3":after.map(func(v):return v.serialize()),
				"e4":end.map(func(v):return v.serialize()),
				"sup":supply.serialize(),
				"e0":start.map(func(v):return v.serialize()),
				"d":damage,
				"l":life,
				"t":time,
			}
		static func deserialize(dic : Dictionary) -> PlayerData:
			var e1 : Array[EffectLog] = []
			var e2 : Array[EffectLog] = []
			var e3 : Array[EffectLog] = []
			var e4 : Array[EffectLog] = []
			var e0 : Array[EffectLog] = []
			e1.assign(dic["e1"].map(func(v):return EffectLog.deserialize(v)))
			e2.assign(dic["e2"].map(func(v):return EffectLog.deserialize(v)))
			e3.assign(dic["e3"].map(func(v):return EffectLog.deserialize(v)))
			e4.assign(dic["e4"].map(func(v):return EffectLog.deserialize(v)))
			e0.assign(dic["e0"].map(func(v):return EffectLog.deserialize(v)))
			
			return PlayerData.new(dic["h"],dic["s"],
					e1,
					EffectLog.deserialize(dic["com"]),
					e2,
					EffectLog.deserialize(dic["res"]),
					e3,
					e4,
					EffectLog.deserialize(dic["sup"]),
					e0,
					dic["d"],dic["l"],dic["t"])

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc:int,np:Phase,p1:PlayerData,p2:PlayerData):
		round_count = rc
		next_phase = np
		myself = p1
		rival = p2

	func serialize() -> Dictionary:
		return {
			"rc":round_count,
			"np":next_phase,
			"m":myself.serialize(),
			"r":rival.serialize(),
		}
	static func deserialize(dic : Dictionary) -> CombatData:
		return CombatData.new(dic["rc"],dic["np"],
				PlayerData.deserialize(dic["m"]),
				PlayerData.deserialize(dic["r"]))

class RecoveryData:
	var round_count : int
	var next_phase : Phase
	var repeat : int

	class PlayerData:
		var hand : PackedInt32Array
		var select : int
		
		var start : Array[EffectLog]
		var result : EffectLog

		var damage:int
		var life:int
		var time:float # remain time
		
		func _init(h:PackedInt32Array,s:int,e0:Array[EffectLog],r:EffectLog,d:int,l:int,t:float):
			hand = h
			select = s
			start = e0
			result = r
			damage = d
			life = l
			time = t

		func serialize() -> Dictionary:
			return {
				"h":hand,
				"s":select,
				"e0":start.map(func(v):return v.serialize()),
				"res":result.serialize(),
				"d":damage,
				"l":life,
				"t":time,
			}
		static func deserialize(dic : Dictionary) -> PlayerData:
			var e0 : Array[EffectLog] = []
			e0.assign(dic["e0"].map(func(v):return EffectLog.deserialize(v))) 
			return PlayerData.new(dic["h"],dic["s"],
					e0,
					EffectLog.deserialize(dic["res"]),
					dic["d"],dic["l"],dic["t"])

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc:int,np:Phase,rp:int,p1:PlayerData,p2:PlayerData):
		round_count = rc
		next_phase = np
		repeat = rp
		myself = p1
		rival = p2

	func serialize() -> Dictionary:
		return {
			"rc":round_count,
			"np":next_phase,
			"rp":repeat,
			"m":myself.serialize(),
			"r":rival.serialize(),
		}
	static func deserialize(dic : Dictionary) -> RecoveryData:
		return RecoveryData.new(dic["rc"],dic["np"],dic["rp"],
				PlayerData.deserialize(dic["m"]),
				PlayerData.deserialize(dic["r"]))

enum EffectSourceType {
	SYSTEM_PROCESS = 0,
	SKILL = 1,
	ENCHANTMENT = 2,
	ABILITY = 3,
}

class EffectLog:
	var type : EffectSourceType
	var id : int
	var priority : int
	var fragment : Array[EffectFragment]
	
	func _init(t : EffectSourceType,i: int,p: int,f: Array[EffectFragment]):
		type = t
		id = i
		priority = p
		fragment = f
		
	func serialize() -> Dictionary:
		return {
			"t":type,
			"i":id,
			"p":priority,
			"f":fragment.map(func(v):return v.serialize()),
		}
	static func deserialize(dic : Dictionary) -> EffectLog:
		var f : Array[EffectFragment] = []
		f.assign(dic["f"].map(func(v):return EffectFragment.deserialize(v)))
		return EffectLog.new(dic["t"],dic["i"],dic["p"],f)

class AbilityLog:
	var ability_id : int
	var card_id : PackedInt32Array
	var fragment : Array[EffectFragment]
	
	func _init(ai : int,ci : PackedInt32Array,f: Array[EffectFragment]):
		ability_id = ai
		card_id = ci
		fragment = f

	func serialize() -> Dictionary:
		return {
			"i":ability_id,
			"c":card_id,
			"f":fragment.map(func(v):return v.serialize()),
		}
	static func deserialize(dic : Dictionary) -> AbilityLog:
		var f : Array[EffectFragment] = []
		f.assign(dic["f"].map(func(v):return EffectFragment.deserialize(v)))
		return AbilityLog.new(dic["i"],dic["c"],f)
	

enum EffectFragmentType {
	NO_EFFECT,		# null
	DAMAGE,			# [unblocked_damage : int,blocked_damage : int]
	RECOVERY,		# recovery point : int
	INITIATIVE,		# initiative : bool
	COMBAT_STATS,	# [power : int,hit : int,block : int]
	
	CARD_STATS,		# [card_id : int,power : int,hit : int,block : int]
	DRAW_CARD,		# card_id : int
	DISCARD_CARD,	# card_id : int
	BOUNCE_CARD,	# [card_id : int,position : int]
	
	CREATE_ENCHANTMENT,	# [enchant_id : int,opponent_source : bool,data_id : int,param : Array]
	UPDATE_ENCHANTMENT,	# [enchant_id : int,param : Array]
	DELETE_ENCHANTMENT,	# [enchant_id : int,expired : bool]
	
	CREATE_CARD,	# [card_id : int,opponent_source : bool,data_id : int,position : int,changes : Dictionary]

	PERFORMANCE,
}

class EffectFragment:
	var type : EffectFragmentType
	var opponent : bool
	var data
	var passive : Array[PassiveLog]
	
	func _init(t: EffectFragmentType,o:bool,d,p:Array[PassiveLog]):
		type = t
		opponent = o
		data = d
		passive = p

	func serialize() -> Dictionary:
		return {
			"t":type,
			"o":opponent,
			"d":data,
			"p":passive.map(func(v):return v.serialize()),
		}
	static func deserialize(dic : Dictionary) -> EffectFragment:
		var p : Array[PassiveLog] = []
		p.assign(dic["p"].map(func(v):return PassiveLog.deserialize(v)))
		return EffectFragment.new(dic["t"],dic["o"],dic["d"],p)


class PassiveLog:
	var opponent : bool
	var enchant_id : int
	var parameter : Array
	
	func _init(o,sid,p):
		opponent = o
		enchant_id = sid
		parameter = p

	func serialize() -> Dictionary:
		return {
			"o":opponent,
			"i":enchant_id,
			"p":parameter,
		}
	static func deserialize(dic : Dictionary) -> PassiveLog:
		return PassiveLog.new(dic["o"],dic["i"],dic["p"])


 # 初期データ（このゲームのルールパラメータとかマッチング時に提出したお互いのデータ）
 # インターフェイスを利用する側はこれが有効になった状態（マッチングが完了した状態）で渡される
func _get_primary_data() -> PrimaryData:
	return null
	

# ゲーム開始準備完了を送信
# これ以後、サーバからrecieved_first_data,recieved_XXX_resultが発生する
func _send_ready():
	pass

#
func _send_combat_select(_round_count:int,_index:int,_hands_order:PackedInt32Array = []):
	pass
#
func _send_recovery_select(_round_count:int,_index:int,_hands_order:PackedInt32Array = []):
	pass

# 即時ゲーム終了（降参）を送信
func _send_surrender():
	pass




class CompleteData:
	var round_count : int
	var next_phase : Phase

	class PlayerData:
		var hand:PackedInt32Array
		var played:PackedInt32Array
		var discard:PackedInt32Array
		var stock:int
		var life:int
		var damage:int
		var enchant:Array[Array] # [id,data_id,opponent_source,param]
		var additional_deck:Array[Array] # [data_id,opponent_source]
		var card_change:Array[Dictionary] # 
		
		func _init(hc,pc,dc,s,l,d,en,ad,cc):
			hand = hc
			played = pc
			discard = dc
			stock = s
			life = l
			damage = d
			enchant = en
			additional_deck = ad
			card_change = cc

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc,np,m,r):
		round_count = rc
		next_phase = np
		myself = m
		rival = r
