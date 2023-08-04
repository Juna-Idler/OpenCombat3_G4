

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

signal recieved_complete_board(data)
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


class FirstData:
	class PlayerData:
		var hand : PackedInt32Array # of int
		var life : int
		var time : float # thinking time
		var initial : Array[EffectLog]	# デッキアビリティ
		var start : Array[EffectLog]	# 開始時効果
		
		func _init(h : PackedInt32Array,l : int,t : float,
				i : Array[EffectLog],s : Array[EffectLog]):
			hand = h
			life = l
			time = t
			initial = i
			start = s

	var myself:PlayerData
	var rival:PlayerData

	func _init(p1:PlayerData,p2:PlayerData):
		myself = p1
		rival = p2


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

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc:int,np:Phase,p1:PlayerData,p2:PlayerData):
		round_count = rc
		next_phase = np
		myself = p1
		rival = p2


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

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc:int,np:Phase,rp:int,p1:PlayerData,p2:PlayerData):
		round_count = rc
		next_phase = np
		repeat = rp
		myself = p1
		rival = p2


enum EffectSourceType {
	SYSTEM_PROCESS = 0,
	SKILL = 1,
	STATE = 2,
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


enum EffectFragmentType {
	NO_EFFECT,		# null
	DAMAGE,			# [unblocked_damage : int,blocked_damage : int]
	INITIATIVE,		# initiative : bool
	COMBAT_STATS,	# [power : int,hit : int,block : int]
	
	CARD_STATS,		# [card_id : int,power : int,hit : int,block : int]
	DRAW_CARD,		# card_id : int
	DISCARD_CARD,	# card_id : int
	BOUNCE_CARD,	# [card_id : int,position : int]
	
	CREATE_STATE,	# [state_id : int,opponent_source : bool,data_id : int,param : Array]
	UPDATE_STATE,	# [state_id : int,param : Array]
	DELETE_STATE,	# [state_id : int,expired : bool]
	
	CREATE_CARD,	# [card_id : int,opponent_source : bool,data_id : int,changes : Dictionary]

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


class PassiveLog:
	var opponent : bool
	var state_id : int
	var parameter : Array
	
	func _init(o,sid,p):
		opponent = o
		state_id = sid
		parameter = p



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
	var next_phase : int

	class PlayerData:
		var hand:PackedInt32Array
		var played:PackedInt32Array
		var discard:PackedInt32Array
		var stock:int
		var life:int
		var damage:int
		var states:Array # of Array [id,data]
		var affected_list:Array # CardData.Stats
		var additional_deck:PackedInt32Array
		
		func _init(hc,pc,dc,s,l,d,st,al,ad):
			hand = hc
			played = pc
			discard = dc
			stock = s
			life = l
			damage = d
			states = st
			affected_list = al
			additional_deck = ad

	var myself:PlayerData
	var rival:PlayerData
	
	func _init(rc,np,m,r):
		round_count = rc
		next_phase = np
		myself = m
		rival = r
