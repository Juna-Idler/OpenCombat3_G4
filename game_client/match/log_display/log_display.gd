extends ScrollContainer

class_name  LogDisplay

class LogSentence:
	var placeholders : PackedStringArray
	var sentence : String
	
	func _init(ph : PackedStringArray,s : String):
		placeholders = ph
		sentence = s

var sentences : Dictionary


const LogItem := preload("res://game_client/match/log_display/log_item.tscn")

var effect_opponent : bool
var fragment_opponent : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	var translation := TranslationServer.get_locale()
	var code := translation.split("_")
	var language := "en" if code.is_empty() else code[0]
	var res = load("res://external_data/match_log_data/log_sentence_%s.txt" % language)
	if not res:
		res = load("res://external_data/match_log_data/log_sentence_en.txt")
	if not res:
		res = load("res://external_data/match_log_data/log_sentence_ja.txt")
	
	var lines := (res.text as String).split("\n")
	for l in lines:
		var tsv := l.split("\t")
		if tsv.size() != 3 or tsv[0].is_empty():
			continue
		var ph : PackedStringArray = PackedStringArray() if tsv[1].is_empty() else tsv[1].split(",")
		sentences[tsv[0]] = LogSentence.new(ph,tsv[2])


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
	var sentence := sentences.get("ROUND_START") as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:str(round_count)})
#	item.text = "ラウンド%d 戦闘フェイズ" % round_count
	$VBoxContainer.add_child(item)

	pass

func append_combat_start(my_card : String,rival_card : String):
	var item = LogItem.instantiate()
	var sentence := sentences.get("COMBAT_START") as LogSentence
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:my_card,
			sentence.placeholders[1]:rival_card})
	$VBoxContainer.add_child(item)

func append_enter_recovery(my_damage : int,rival_damage : int):
	var item = LogItem.instantiate()
	var sentence := sentences.get("ENTER_RECOVERY") as LogSentence
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:my_damage,
			sentence.placeholders[1]:rival_damage
	})

func append_timing(timing : I_PlayerField.EffectTiming):
	const timing_table := {
			I_PlayerField.EffectTiming.INITIAL:"TIMING_INITIAL",
			I_PlayerField.EffectTiming.START:"TIMING_START",
			I_PlayerField.EffectTiming.BEFORE:"TIMING_BEFORE",
			I_PlayerField.EffectTiming.MOMENT:"TIMING_MOMENT",
			I_PlayerField.EffectTiming.AFTER:"TIMING_AFTER",
			I_PlayerField.EffectTiming.END:"TIMING_END",
			}
	var item = LogItem.instantiate()
	var sentence := sentences.get(timing_table.get(timing)) as LogSentence
	item.text = sentence.sentence
	if delayed_timing:
		delayed_timing.queue_free()
	delayed_timing = item
#	$VBoxContainer.add_child(item)

func append_combat_comparison_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	var sentence := sentences.get("COMBAT_COMPARISON") as LogSentence
	item.text = sentence.sentence
	$VBoxContainer.add_child(item)

func append_combat_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	var sentence := sentences.get("COMBAT_RESULT") as LogSentence
	item.text = sentence.sentence
	$VBoxContainer.add_child(item)

func append_combat_supply_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	var sentence := sentences.get("COMBAT_SUPPLY") as LogSentence
	item.text = sentence.sentence
	$VBoxContainer.add_child(item)
	
func append_recovery_result_effect():
	effect_opponent = false
	var item = LogItem.instantiate()
	var sentence := sentences.get("RECOVERY_RESULT") as LogSentence
	item.text = sentence.sentence
	$VBoxContainer.add_child(item)

func append_ability(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("ABILITY_ACTIVATE_2" if effect_opponent else "ABILITY_ACTIVATE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
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
	var sentence := (sentences.get("SKILL_ACTIVATE_2" if effect_opponent else "SKILL_ACTIVATE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item

func append_effect_enchant(title : String,opponent : bool):
	effect_opponent = opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("ENCHANTMENT_ACTIVATE_2" if effect_opponent else "ENCHANTMENT_ACTIVATE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
	if delayed_effect:
		delayed_effect.queue_free()
	delayed_effect = item


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
	var sentence := (sentences.get("DAMAGE_2" if fragment_opponent else "DAMAGE_1")) as LogSentence
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:unblocked_damage,
			sentence.placeholders[1]:blocked_damage,
	})
	_append_fragment_log_item(item)

func append_fragment_recovery(recovery_point : int,remaining_damage : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("RECOVERY_2" if fragment_opponent else "RECOVERY_1")) as LogSentence
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:recovery_point,
			sentence.placeholders[1]:remaining_damage,
	})
	_append_fragment_log_item(item)
	
func append_fragment_initiative(i : bool,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence : LogSentence
	if fragment_opponent:
		sentence = sentences.get("INITIATIVE_GET_2" if i else "INITIATIVE_LOST_2")
	else:
		sentence = sentences.get("INITIATIVE_GET_1" if i else "INITIATIVE_LOST_1")
	item.text = sentence.sentence
	_append_fragment_log_item(item)

func append_initiative_draw():
	var item = LogItem.instantiate()
	var sentence : LogSentence = sentences.get("INITIATIVE_DRAW")
	item.text = sentence.sentence
	$VBoxContainer.add_child(item)


func append_fragment_combat_stats(p : int,h : int,b : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("COMBAT_STATS_2" if fragment_opponent else "COMBAT_STATS_1")) as LogSentence
	var stats := "(%d/%d/%d)" % [p,h,b]
	item.text = sentence.sentence.format({sentence.placeholders[0]:stats})
	_append_fragment_log_item(item)
	
func append_fragment_card_stats(card : String,p : int,h : int,b : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("CARD_STATS_2" if fragment_opponent else "CARD_STATS_1")) as LogSentence
	var stats := "(%d/%d/%d)" % [p,h,b]
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:card,
			sentence.placeholders[1]:stats,
	})
	_append_fragment_log_item(item)
	
func append_fragment_draw(card : String,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("DRAW_CARD_2" if fragment_opponent else "DRAW_CARD_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:card})
	_append_fragment_log_item(item)

func append_fragment_no_draw(opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("DRAW_NO_CARD_2" if fragment_opponent else "DRAW_NO_CARD_1")) as LogSentence
	item.text = sentence.sentence
	_append_fragment_log_item(item)
	
func append_fragment_discard(card : String,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("DISCARD_CARD_2" if fragment_opponent else "DISCARD_CARD_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:card})
	_append_fragment_log_item(item)

func append_fragment_bounce(card : String,stock_position : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("BOUNCE_CARD_2" if fragment_opponent else "BOUNCE_CARD_1")) as LogSentence
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:card,
			sentence.placeholders[0]:str(stock_position),
	})
	_append_fragment_log_item(item)

func append_fragment_create_enchant(title : String,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("ENCHANT_2" if fragment_opponent else "ENCHANT_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
	_append_fragment_log_item(item)

func append_fragment_update_enchant(title : String,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("ENCHANT_UPDATE_2" if fragment_opponent else "ENCHANT_UPDATE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
	_append_fragment_log_item(item)

func append_fragment_delete_enchant(title : String,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("ENCHANT_DELETE_2" if fragment_opponent else "ENCHANT_DELETE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title})
	_append_fragment_log_item(item)

func append_fragment_create_card(card : Card3D,deck_position : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("CARD_CREATE_2" if fragment_opponent else "CARD_CREATE_1")) as LogSentence
	var title := "%s(%d/%d/%d:%d)" % [card.card_name,card.power,card.hit,card.block,card.level]
	item.text = sentence.sentence.format({
			sentence.placeholders[0]:title,
			sentence.placeholders[1]:deck_position,
	})
	_append_fragment_log_item(item)

func append_passive(title : String,opponent : bool):
	var passive_opponent : bool = fragment_opponent != opponent
	var item = LogItem.instantiate()
	var sentence := (sentences.get("PASSIVE_2" if passive_opponent else "PASSIVE_1")) as LogSentence
	item.text = sentence.sentence.format({sentence.placeholders[0]:title,})
	$VBoxContainer.add_child(item)



func _on_v_box_container_child_entered_tree(_node):
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_callback(func():scroll_vertical = $VBoxContainer.size.y)

