extends SceneChanger.IScene

var _scene_changer : SceneChanger

const DeckTitle := preload("res://game_client/deck_build/deck_title.tscn")
const Card := preload("res://game_client/deck_build/building/card.tscn")

var select : Control = null :
	set(v):
		if select:
			select.set_border_color(Color.WHITE)
		select = v
		select.set_border_color(Color.RED)

var _hold_deck : DeckData = null

func _ready():
#	_initialize(null,[])
	pass

func _on_deck_title_clicked(deck_title):
	select = deck_title
	Global.basic_deck_list.select = %VBoxContainer.get_children().find(deck_title)

func _on_deck_title_held(deck_title):
	
	_hold_deck = deck_title.get_deck()
	$DeckList.show()
	$DeckList/DeckList.initialize_from_deck(_hold_deck,[],false)
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
	for i in Global.basic_deck_list.list:
		var t := DeckTitle.instantiate()
		t.initialize(i)
		t.clicked.connect(_on_deck_title_clicked.bind(t))
		t.held.connect(_on_deck_title_held.bind(t))
		t.timer = $Menu/Timer
		%VBoxContainer.add_child(t)
	
	if %VBoxContainer.get_child_count() > 0:
		select = %VBoxContainer.get_child(Global.basic_deck_list.select)


func _fade_in_finished():
	pass


func _terminalize():
	pass


func _on_button_edit_pressed():
	if not select:
		return
		
	$Menu.hide()
	$Building.show()
	$Building.initialize(select.get_deck())
	


func _on_button_new_pressed():
	var t := DeckTitle.instantiate()
	var dd := DeckData.new("new deck",Global.card_catalog,[])
	t.initialize(dd)
	t.clicked.connect(_on_deck_title_clicked.bind(t))
	%VBoxContainer.add_child(t)
	select = t


func _on_building_exit():
	$Menu.show()
	$Building.hide()


func _on_building_saved(deck):
	select.initialize(deck)
	Global.basic_deck_list.list.assign(%VBoxContainer.get_children().map(func(v):return v.get_deck()))
	Global.basic_deck_list.save_deck_list()


func _on_button_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])



func _on_building_request_card_detail(cd):
	$CardDetail.show()
	$CardDetail/CardDetail.initialize_origin(cd)


func _on_card_detail_gui_input(event):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		$CardDetail.hide()



func _on_deck_list_card_clicked(_index):
	if not _hold_deck:
		return
	var cd := _hold_deck.catalog._get_card_data(_hold_deck.cards[_index])
	$CardDetail.show()
	$CardDetail/CardDetail.initialize_origin(cd)



func _on_building_request_deck_list(deck):
	$DeckList.show()
	$DeckList/DeckList.initialize_from_deck(deck,[],true)


func _on_button_deck_list_close_pressed():
	if _hold_deck:
		_hold_deck = null
	else:
		$Building.reset_card_order($DeckList/DeckList.get_order())
		
	$DeckList.hide()
	$DeckList/DeckList.terminalize()
	
	
