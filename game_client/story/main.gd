extends SceneChanger.IScene

var _scene_changer : SceneChanger

var vs_enemy_server :=  VsEnemyServer.new()

const PlayablePlayerFieldScene := preload("res://game_client/match/field/player/playable_field.tscn")
const EnemyFieldScene := preload("res://game_client/match/field/enemy/enemy_field.tscn")


var myself : PlayablePlayerField
var enemy : EnemyField

var enemy_data : EnemyData


@onready var panel_deck_list = $CanvasLayerCardList/PanelDeckList
@onready var deck_list = $CanvasLayerCardList/PanelDeckList/DeckList
@onready var panel_card_detail = $CanvasLayerCardList/PanelCardDetail
@onready var card_detail = $CanvasLayerCardList/PanelCardDetail/CardDetail



func _ready():
	_initialize(null,[])

func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
	myself = PlayablePlayerFieldScene.instantiate()
	myself.hand_selected.connect(on_hand_selected)
	enemy = EnemyFieldScene.instantiate()

	enemy_data = EnemyDataFactory.create("dummy")
	var e_catalog := enemy_data.factory._get_catalog()
	Global.catalog_factory.register(e_catalog._get_catalog_name(),e_catalog)

	var my_deck : PackedInt32Array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	
	vs_enemy_server.initialize(Global.game_settings.player_name,my_deck,Global.card_catalog,
			enemy_data)

	$match_scene.initialize(vs_enemy_server,myself,enemy)
	
	vs_enemy_server._send_ready()

	pass
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass

func on_hand_selected(index : int,hand : Array[Card3D]):
	myself.hand_area.set_playable(false)
	var order : PackedInt32Array = []
	for h in hand:
		order.append(h.id_in_deck)
	match $match_scene.phase:
		IGameServer.Phase.COMBAT:
			vs_enemy_server._send_combat_select($match_scene.round_count,index,order)
		IGameServer.Phase.RECOVERY:
			vs_enemy_server._send_recovery_select($match_scene.round_count,index,order)
		IGameServer.Phase.GAME_END:
			pass
	await myself.fix_select_card(hand[index])
	pass

func _on_match_scene_performed():
	if vs_enemy_server.non_playable_recovery_phase:
		vs_enemy_server._send_recovery_select($match_scene.round_count,-1)
		return
	if $match_scene.phase != IGameServer.Phase.GAME_END:
		myself.hand_area.set_playable(true)
	else:
		pass

	


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
		

