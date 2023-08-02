extends ScrollContainer

class_name  LogDisplay

const LogItem := preload("res://game_client/match/log_display/log_item.tscn")

var effect_opponent : bool
var fragment_opponent : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear():
	for c in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(c)
		c.queue_free()

func append_round(round_count : int):
	var item = LogItem.instantiate()
	item.text = "ラウンド%d" % round_count
	$VBoxContainer.add_child(item)
	pass

func append_timing(timing : I_MatchPlayer.EffectTiming):
	var text : String = ""
	match timing:
		I_MatchPlayer.EffectTiming.INITIAL:
			text = "デッキ効果"
			pass
		I_MatchPlayer.EffectTiming.START:
			text = "開始時効果"
			pass
		I_MatchPlayer.EffectTiming.BEFORE:
			text = "交戦前効果"
			pass
		I_MatchPlayer.EffectTiming.MOMENT:
			text = "交戦時効果"
			pass
		I_MatchPlayer.EffectTiming.AFTER:
			text = "交戦後効果"
			pass
		I_MatchPlayer.EffectTiming.END:
			text = "終了時効果"
			pass
	var item = LogItem.instantiate()
	item.text = text
	$VBoxContainer.add_child(item)

func append_combat_start(my_card : String,rival_card : String):
	var item = LogItem.instantiate()
	item.text = """戦闘フェイズ
自分のカード:%s
相手のカード:%s""" % [my_card,rival_card] 
	$VBoxContainer.add_child(item)
	

func append_combat_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "交戦結果"
	$VBoxContainer.add_child(item)
	pass
	
func append_recovery_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "回復結果"
	$VBoxContainer.add_child(item)
	pass

func append_effect_system(opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = "相手のシステム効果" if effect_opponent else "自分のシステム効果"
	$VBoxContainer.add_child(item)
	pass

func append_effect_skill(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("スキル:%sの効果" % title)
	$VBoxContainer.add_child(item)
	pass

func append_effect_enchant(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("エンチャント:%sの効果" % title)
	$VBoxContainer.add_child(item)
	pass

func append_effect_ability(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("アビリティ:%sの効果" % title)
	$VBoxContainer.add_child(item)
	pass

func append_fragment_damage(unblocked_damage : int,blocked_damage : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手に" if fragment_opponent else "自分に") +\
			("%dダメージ/%dブロック" % [unblocked_damage,blocked_damage])
	$VBoxContainer.add_child(item)
	pass
	
func append_fragment_initiative():
	pass
func append_fragment_combat_stats(p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("戦闘カードが%d/%d/%dに変動" % [p,h,b])
	$VBoxContainer.add_child(item)
	
	pass
func append_fragment_card_stats(card : String,p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("カード:%sが%d/%d/%dに変動" % [card,p,h,b])
	$VBoxContainer.add_child(item)
	pass
	
func append_fragment_draw(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("カード:%sを手札に加えた" % card)
	$VBoxContainer.add_child(item)	
	pass
func append_fragment_discard(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("カード:%sを捨てた" % card)
	$VBoxContainer.add_child(item)
	pass
func append_fragment_bounce(card : String,stock_position,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("カード:%sをデッキに戻した（位置:%s）" % [card,stock_position])
	$VBoxContainer.add_child(item)	
	pass

func append_fragment_create_enchant(title,_opponent_soucer,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手に" if fragment_opponent else "自分に") +\
			("エンチャント:%sが発生" % title)
	$VBoxContainer.add_child(item)

	pass
func append_fragment_update_enchant(title,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("エンチャント:%sが更新" % title)
	pass
func append_fragment_delete_enchant(title,_expired,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("エンチャント:%sが消滅" % title)
	pass

func append_fragment_create_card():
	pass


func append_passive(title,opponent):
	var passive_opponent : bool = fragment_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + "　" + "パッシブ:" + ("相手の" if passive_opponent else "自分の") +\
			("%sが変動" % title)
	
