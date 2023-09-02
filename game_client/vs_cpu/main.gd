extends SceneChanger.IScene

var _scene_changer : SceneChanger

var offline_server := OfflineServer.new()
var logger := MatchLogger.new()

var server : IGameServer = null
var catalog := CardCatalog.new()

const PlayablePlayerFieldScene := preload("res://game_client/match/player/field/playable_field.tscn")
const NonPlayablePlayerFieldScene := preload("res://game_client/match/player/field/non_playable_field.tscn")


var myself : PlayablePlayerField
var rival : NonPlayablePlayerField

@onready var game_end = $CanvasLayerMatch/GameEnd
@onready var menu = $CanvasLayerMenu/Menu
@onready var panel_deck_list = $CanvasLayerCardList/PanelDeckList
@onready var deck_list = $CanvasLayerCardList/PanelDeckList/DeckList
@onready var panel_card_detail = $CanvasLayerCardList/PanelCardDetail
@onready var card_detail = $CanvasLayerCardList/PanelCardDetail/CardDetail



func _ready():
	pass
#	initialize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
	menu.initialize()
	
	game_end.hide()
	%Settings.hide()
	panel_card_detail.hide()
	panel_deck_list.hide()
	menu.show()
	
	myself = PlayablePlayerFieldScene.instantiate()
	myself.hand_selected.connect(on_hand_selected)
	rival = NonPlayablePlayerFieldScene.instantiate()


func _fade_in_finished():
	pass


func on_hand_selected(index : int,hand : Array[Card3D]):
	myself.hand_area.set_playable(false)
	var order : PackedInt32Array = []
	for h in hand:
		order.append(h.id_in_deck)
	match $match_scene.phase:
		IGameServer.Phase.COMBAT:
			server._send_combat_select($match_scene.round_count,index,order)
		IGameServer.Phase.RECOVERY:
			server._send_recovery_select($match_scene.round_count,index,order)
		IGameServer.Phase.GAME_END:
			pass
	await myself.fix_select_card(hand[index])
	pass

func _on_match_scene_performed():
	if offline_server.non_playable_recovery_phase:
		server._send_recovery_select($match_scene.round_count,-1)
		return
	if $match_scene.phase != IGameServer.Phase.GAME_END:
		myself.hand_area.set_playable(true)
	else:
		if game_end.visible:
			return
		game_end.show()
		var mp : int = $match_scene.my_game_end_point
		var rp : int = $match_scene.rival_game_end_point
		
		if mp > rp:
			game_end.get_node("Label").text = "You Win %d:%d" % [mp,rp]
		elif mp < rp:
			game_end.get_node("Label").text = "You Lose %d:%d" % [mp,rp]
		else:
			game_end.get_node("Label").text = "Draw %d:%d" % [mp,rp]
			pass
		var time_string := "%.3f" % Time.get_unix_time_from_system()
		MatchLogFile.save_log("user://replay/" + time_string + ".replay_log",logger.match_log)
	
func _on_match_scene_ended(msg : String):
		game_end.show()
		
		game_end.get_node("Label").text = "Game End:\n" + msg
		var time_string := "%.3f" % Time.get_unix_time_from_system()
		MatchLogFile.save_log("user://replay/" + time_string + ".replay_log",logger.match_log)
		


func _on_button_game_over_2_pressed():
	menu.show()
	game_end.hide()
	%Settings.hide()


func _on_button_settings_pressed():
	%Settings.show()


func _on_button_surrender_pressed():
	server._send_surrender()
	%Settings.hide()


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


func _on_menu_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])


func _on_menu_start_pressed():
	menu.hide()
	game_end.hide()
	%Settings.hide()
	
	var my_deck = menu.get_my_deck()
	var cpu_deck = menu.get_cpu_deck()
	var d := RegulationData.DeckRegulation.new("",27,30,2,1,"1-27")
	var m := RegulationData.MatchRegulation.new("",4,60,10,5)
	
	offline_server.initialize(Global.game_settings.player_name,my_deck.cards,my_deck.catalog,
			ICpuCommander.ZeroCommander.new(),cpu_deck.cards,cpu_deck.catalog,d,m)
	logger.initialize(offline_server)
	server = logger
	$match_scene.initialize(server,myself,rival,my_deck.catalog,cpu_deck.catalog)
	
	server._send_ready()


var current_deck_data : DeckData
func _on_menu_request_deck_list(deck_data):
	current_deck_data = deck_data
	panel_deck_list.show()
	deck_list.initialize_from_deck(deck_data,[],false)


func _on_deck_list_card_clicked(_index):
	var cd := current_deck_data.catalog._get_card_data(current_deck_data.cards[_index])
	panel_card_detail.show()
	card_detail.initialize_origin(cd)
