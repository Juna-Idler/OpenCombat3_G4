extends Node2D

const EnchantmentTitleScene := preload("res://game_client/match/player/field/enchant_display/enchantment_title.tscn")
enum EnchantmentState {NORMAL,ACTIVATE,DELETE}

class Enchantment:
	var data : CatalogData.StateData
	var title : String
	var title_object : EnchantmentTitle = EnchantmentTitleScene.instantiate()

	func _init(d,p,o):
		data = d
		var p_str := Global.card_catalog.param_to_string(data.param_type,p)
		title = data.name + ("" if p_str.is_empty() else "(" + p_str + ")" )
		title_object.initialize(title,o)
	
	func change_parameter(p):
		var p_str := Global.card_catalog.param_to_string(data.param_type,p)
		title = data.name + ("" if p_str.is_empty() else "(" + p_str + ")" )
		title_object.update(title)

var _enchantments : Dictionary = {} # key int, value Enchantment

var _deleted : PackedInt32Array = []

var _opponent_layout : bool

var _log_display : LogDisplay


func _ready():
	pass # Replace with function body.
	
func initialize(log_display : LogDisplay,opponent : bool):
	_log_display = log_display
	_opponent_layout = opponent
	
func get_enchantment_data(id : int) -> CatalogData.StateData:
	return _enchantments[id].data

func create_enchantment(id : int,sd : CatalogData.StateData,param,opponent : bool):
	var n := Enchantment.new(sd,param,_opponent_layout)
	_enchantments[id] = n
	add_child(n.title_object)

	_log_display.append_fragment_create_enchant(n.title,opponent)

	var size := _enchantments.size()
	var start := size * -20 + 20
	n.title_object.position = Vector2(320,start + (size - 1) * 40)
	var count : int = 0
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	for v in _enchantments.values():
		var e := v as Enchantment
		tween.tween_property(e.title_object,"position:y",start + count * 40,0.1)
		count += 1
	tween.tween_property(n.title_object,"position:x",0.0,0.1)
	await tween.finished


func update_enchantment(id : int,param,opponent : bool,duration : float = 0.2):
	var e := _enchantments[id] as Enchantment
	e.change_parameter(param)
	_log_display.append_fragment_update_enchant(e.title,opponent)
	
	var origin := e.title_object.modulate
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(e.title_object,"modulate",Color(1,0,0,1),duration/2)
	tween.tween_property(e.title_object,"modulate",origin,duration/2)
	await tween.finished


func delete_enchantment(id : int,expired : bool,opponent : bool):
	var d := _enchantments[id] as Enchantment
	_deleted.append(id)
	_log_display.append_fragment_delete_enchant(d.title,opponent)
	
	if not expired:
		d.title_object.modulate.a = 0.5
		return
		
	var size := _enchantments.size() - 1
	var start := size * -20 + 20
	var count : int = 0
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	for v in _enchantments.values():
		var e := v as Enchantment
		if e != d:
			tween.tween_property(e.title_object,"position:y",start + count * 40,0.1)
			count += 1
	tween.tween_property(d.title_object,"position:x",320.0,0.1)
	await tween.finished
	d.title_object.visible = false


func force_delete():
	if _deleted.is_empty():
		return
	var size := _enchantments.size() - _deleted.size()
	var start := size * -20 + 20
	var count : int = 0
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	for k in _enchantments:
		var e := _enchantments[k] as Enchantment
		if not _deleted.has(k):
			tween.tween_property(e.title_object,"position:y",start + count * 40,0.1)
			count += 1
	for d in _deleted:
		var e := _enchantments[d] as Enchantment
		if e.title_object.visible:
			tween.tween_property(e.title_object,"position:x",320.0,0.1)
	await tween.finished
	for d in _deleted:
		var e = _enchantments[d] as Enchantment
		remove_child(e.title_object)
		e.title_object.queue_free()
		_enchantments.erase(d)
	_deleted.clear()


func perform(id : int):
	var e := _enchantments[id] as Enchantment
	_log_display.append_effect_enchant(e.title,_opponent_layout)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(e.title_object,"position:x",-320,0.3)
	tween.tween_interval(0.2)
	tween.tween_property(e.title_object,"position:x",0,0.3)
	await tween.finished
	

func get_title(id : int,param) -> String:
	var e := _enchantments[id] as Enchantment
	var p_str := Global.card_catalog.param_to_string(e.data.param_type,param)
	return e.data.name + ("" if p_str.is_empty() else "(" + p_str + ")" )
