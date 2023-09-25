extends Node


class_name StoryBattle

signal battle_finished

var battle_result : int


var vs_enemy_server :=  VsEnemyServer.new()

const PlayablePlayerFieldScene := preload("res://game_client/match/field/player/playable_field.tscn")
const EnemyFieldScene := preload("res://game_client/match/field/enemy/enemy_field.tscn")

var myself : PlayablePlayerField
var enemy : EnemyField

var enemy_data : EnemyData

var battle_script : I_BattleScript

@onready var match_scene = $match_scene

@onready var panel_deck_list = $CanvasLayerCardList/PanelDeckList
@onready var deck_list = $CanvasLayerCardList/PanelDeckList/DeckList
@onready var panel_card_detail = $CanvasLayerCardList/PanelCardDetail
@onready var card_detail = $CanvasLayerCardList/PanelCardDetail/CardDetail



func _ready():
	pass

func _process(_delta):
	pass


func initialize(my_deck : PackedInt32Array,enemy_name : String,bs : I_BattleScript):
	
	myself = PlayablePlayerFieldScene.instantiate()
	myself.hand_selected.connect(on_hand_selected)
	enemy = EnemyFieldScene.instantiate()

	enemy_data = EnemyDataFactory.create(enemy_name)
	enemy.set_avatar_texture(enemy_data.enemy_image)
	var e_catalog := enemy_data.catalog
	Global.catalog_factory.register(e_catalog._get_catalog_name(),e_catalog)
	
	battle_script = bs

	vs_enemy_server.initialize(Global.game_settings.player_name,my_deck,Global.card_catalog,
			enemy_data)

	match_scene.initialize(vs_enemy_server,myself,enemy)
	
	await battle_script._start_event()
	
	vs_enemy_server._send_ready()


func terminalize():
	match_scene.terminalize()
	myself.hand_selected.disconnect(on_hand_selected)
	myself.queue_free()
	enemy.queue_free()
	Global.catalog_factory.delete(enemy_data.catalog._get_catalog_name())
	

func on_hand_selected(index : int,hand : Array[Card3D]):
	myself.hand_area.set_playable(false)
	var data := I_BattleScript.Data.new(match_scene.round_count,match_scene.phase)
	if not await battle_script._hand_selected_event(data):
		battle_result = -1
		battle_finished.emit()
		return
	
	var order : PackedInt32Array = []
	for h in hand:
		order.append(h.id_in_deck)
	match match_scene.phase:
		IGameServer.Phase.COMBAT:
			vs_enemy_server._send_combat_select(match_scene.round_count,index,order)
		IGameServer.Phase.RECOVERY:
			vs_enemy_server._send_recovery_select(match_scene.round_count,index,order)
		IGameServer.Phase.GAME_END:
			pass
	await myself.fix_select_card(hand[index])
	pass

func _on_match_scene_performed():
	var data := I_BattleScript.Data.new(match_scene.round_count,match_scene.phase)
	if not await battle_script._performed_event(data):
		battle_result = -1
		battle_finished.emit()
		return
	
	if vs_enemy_server.non_playable_recovery_phase:
		vs_enemy_server._send_recovery_select(match_scene.round_count,-1)
		return
	if match_scene.phase == IGameServer.Phase.GAME_END:
#		match_scene.my_game_end_point
		if match_scene.rival_game_end_point <= 0:
			battle_result = 1
		else:
			battle_result = 0
		await battle_script._end_event()
		battle_finished.emit()
	else:
		myself.hand_area.set_playable(true)


func _on_panel_deck_list_gui_input(event):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		panel_deck_list.hide()
		deck_list.terminalize()

func _on_button_deck_list_close_pressed():
	panel_deck_list.hide()
	deck_list.terminalize()
	
	

func _on_card_detail_gui_input(event):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		panel_card_detail.hide()

func _on_match_scene_request_card_detail(cd, color, level, power, hit, block, skills, picture):
	if cd:
		panel_card_detail.show()
		card_detail.initialize(cd, color, level, power, hit, block, skills, picture)
	else:
		panel_card_detail.hide()
		

