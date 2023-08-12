extends ScrollContainer

class_name  LogDisplay

const LogItem := preload("res://game_client/match/log_display/log_item.tscn")

var effect_opponent : bool
var fragment_opponent : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open():
	scroll_vertical = $VBoxContainer.size.y
	pass

func clear():
	for c in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(c)
		c.queue_free()


var delayed_timing : Node = null
var delayed_effect : Node = null


func append_round(round_count : int):
	var item = LogItem.instantiate()
	item.text = "ラウンド%d 戦闘フェイズ" % round_count
	$VBoxContainer.add_child(item)

	pass

func append_combat_start(my_card : String,rival_card : String):
	var item = LogItem.instantiate()
	item.text = """戦闘開始
自分のカード:%s
相手のカード:%s""" % [my_card,rival_card] 
	$VBoxContainer.add_child(item)


func append_enter_recovery(my_damage : int,rival_damage : int):
	var item = LogItem.instantiate()
	item.text = """回復フェイズ
自分のダメージ:%d
相手のダメージ:%d""" % [my_damage,rival_damage] 
	$VBoxContainer.add_child(item)

	pass

func append_timing(timing : I_PlayerField.EffectTiming):
	var text : String = ""
	match timing:
		I_PlayerField.EffectTiming.INITIAL:
			text = "デッキ効果タイミング"
			pass
		I_PlayerField.EffectTiming.START:
			text = "開始時効果タイミング"
			pass
		I_PlayerField.EffectTiming.BEFORE:
			text = "交戦前効果タイミング"
			pass
		I_PlayerField.EffectTiming.MOMENT:
			text = "交戦時効果タイミング"
			pass
		I_PlayerField.EffectTiming.AFTER:
			text = "交戦後効果タイミング"
			pass
		I_PlayerField.EffectTiming.END:
			text = "終了時効果タイミング"
			pass
	var item = LogItem.instantiate()
	item.text = text
	if delayed_timing:
		delayed_timing.queue_free()
	delayed_timing = item
#	$VBoxContainer.add_child(item)

func append_combat_comparison_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "Power比較"
	$VBoxContainer.add_child(item)
	pass

func append_combat_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "交戦結果"
	$VBoxContainer.add_child(item)
	pass

func append_combat_supply_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "カード補充"
	$VBoxContainer.add_child(item)
	pass
	
func append_recovery_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	item.text = "回復結果"
	$VBoxContainer.add_child(item)
	pass

func append_ability(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("アビリティ：「%s」が発動" % title)
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item
	

func append_effect_system(opponent : bool):
	effect_opponent = opponent
#	var item = LogItem.instantiate()
#	item.text = "相手のシステム効果" if effect_opponent else "自分のシステム効果"
#	$VBoxContainer.add_child(item)
	pass

func append_effect_skill(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("スキル:「%s」が発動" % title)
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item
#	$VBoxContainer.add_child(item)
	pass

func append_effect_enchant(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("エンチャント:「%s」が発動" % title)
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item
#	$VBoxContainer.add_child(item)
	pass

func append_effect_ability(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	item.text = ("相手の" if effect_opponent else "自分の") + ("アビリティ:「%s」が発動" % title)
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item
#	$VBoxContainer.add_child(item)
	pass


func _append_fragment_log_item(item : Control):
	if delayed_effect:
		if delayed_timing:
			$VBoxContainer.add_child(delayed_timing)
			delayed_timing = null
		$VBoxContainer.add_child(delayed_effect)
		delayed_effect = null
	$VBoxContainer.add_child(item)

	

func append_fragment_damage(unblocked_damage : int,blocked_damage : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手に" if fragment_opponent else "自分に") +\
			("%dダメージ/%dブロック" % [unblocked_damage,blocked_damage])
	_append_fragment_log_item(item)
	pass

func append_fragment_recovery(recovery_point : int,remaining_damage : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("%d回復/残り%dダメージ" % [recovery_point,remaining_damage])
	_append_fragment_log_item(item)
	pass
	
func append_fragment_initiative(i : bool,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	if i:
		item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
				("主導権を得た")
	else:
		item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
				("主導権を失った")
	_append_fragment_log_item(item)
	pass
	
func append_fragment_combat_stats(p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("戦闘カードが%d/%d/%dに変動" % [p,h,b])
	_append_fragment_log_item(item)
	
	pass
func append_fragment_card_stats(card : String,p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("「%s」が%d/%d/%dに変動" % [card,p,h,b])
	_append_fragment_log_item(item)
	pass
	
func append_fragment_draw(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("「%s」をドロー" % card)
	_append_fragment_log_item(item)
	pass

func append_fragment_no_draw(opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("カードをドロー出来なかった")
	_append_fragment_log_item(item)
	
func append_fragment_discard(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("「%s」を捨てた" % card)
	_append_fragment_log_item(item)
	pass
func append_fragment_bounce(card : String,stock_position,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("「%s」をデッキに戻した（位置:%s）" % [card,stock_position])
	_append_fragment_log_item(item)
	pass

func append_fragment_create_enchant(title,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手に" if fragment_opponent else "自分に") +\
			("エンチャント「%s」が発生" % title)
	_append_fragment_log_item(item)

	pass
func append_fragment_update_enchant(title,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("エンチャント「%s」が更新" % title)
	_append_fragment_log_item(item)
	pass
func append_fragment_delete_enchant(title,opponent):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手の" if fragment_opponent else "自分の") +\
			("エンチャント「%s」が消滅" % title)
	_append_fragment_log_item(item)
	pass

func append_fragment_create_card(card : Card3D,deck_position : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + ("相手は" if fragment_opponent else "自分は") +\
			("カード「%s」(%d/%d/%d:%d)を位置%dに生成" % [card.card_name,card.power,card.hit,card.block,card.level,deck_position])
	_append_fragment_log_item(item)
	pass


func append_passive(title,opponent):
	var passive_opponent : bool = fragment_opponent != opponent
	var item = LogItem.instantiate()
	item.text = "　" + "　" + "パッシブ:" + ("相手の" if passive_opponent else "自分の") +\
			("「%s」が変動" % title)
	$VBoxContainer.add_child(item)



func _on_v_box_container_child_entered_tree(_node):
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_callback(func():scroll_vertical = $VBoxContainer.size.y)
	pass # Replace with function body.
