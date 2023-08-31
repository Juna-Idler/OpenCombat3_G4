extends SceneChanger.IScene

var _scene_changer : SceneChanger

const DeckTitle := preload("res://game_client/deck_build/deck_title.tscn")

var select : Control = null :
	set(v):
		if select:
			select.set_border_color(Color.WHITE)
		select = v
		select.set_border_color(Color.RED)


func _ready():
#	_initialize(null,[])
	pass

func _on_deck_title_clicked(deck_title):
	select = deck_title
	Global.basic_deck_list.select = %VBoxContainer.get_children().find(deck_title)


func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	
	for i in Global.basic_deck_list.list:
		var t := DeckTitle.instantiate()
		t.initialize(i)
		t.clicked.connect(_on_deck_title_clicked.bind(t))
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
	$building.show()
	$building.initialize(select.get_deck())
	


func _on_button_new_pressed():
	var t := DeckTitle.instantiate()
	var dd := DeckData.new("new deck",Global.card_catalog,[])
	t.initialize(dd)
	t.clicked.connect(_on_deck_title_clicked.bind(t))
	%VBoxContainer.add_child(t)
	select = t


func _on_building_exit():
	$Menu.show()
	$building.hide()


func _on_building_saved(deck):
	select.initialize(deck)
	Global.basic_deck_list.list.assign(%VBoxContainer.get_children().map(func(v):return v.get_deck()))
	Global.basic_deck_list.save_deck_list()


func _on_button_back_pressed():
	_scene_changer.goto_scene("res://game_client/title/title_scene.tscn",[])

