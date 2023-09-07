extends Panel


signal back_pressed
signal start_pressed

signal request_deck_list(deck_data : DeckData)


const DeckTitle := preload("res://game_client/deck_build/deck_title.tscn")

@onready var v_box_container = %VBoxContainer

var deck_select_target : Control = null

func initialize():
	for i in Global.basic_deck_list.list:
		var t := DeckTitle.instantiate()
		t.initialize(i)
		t.clicked.connect(_on_deck_title_clicked.bind(t))
		t.held.connect(_on_deck_title_held.bind(t))
		t.timer = $Timer
		v_box_container.add_child(t)
	
	if v_box_container.get_child_count() > 0:
		var deck = v_box_container.get_child(Global.basic_deck_list.select).get_deck()
		$MyDeck.initialize(deck)
		$CpuDeck.initialize(deck)
		$MyDeck.held.connect(_on_deck_title_held.bind($MyDeck))
		$MyDeck.timer = $Timer
		$CpuDeck.held.connect(_on_deck_title_held.bind($CpuDeck))
		$CpuDeck.timer = $Timer
	else:
		$ButtonStart.disabled = true


func get_my_deck() -> DeckData:
	return $MyDeck.get_deck()

func get_cpu_deck() -> DeckData:
	return $CpuDeck.get_deck()

func get_shuffle() -> bool:
	return $CheckButtonShuffle.button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_deck_title_clicked(deck_title):
	deck_select_target.initialize(deck_title.get_deck())
	$DeckSelect.hide()

func _on_deck_title_held(deck_title):
	request_deck_list.emit(deck_title.get_deck())
	pass


func _on_button_back_pressed():
	back_pressed.emit()

func _on_button_start_pressed():
	start_pressed.emit()


func _on_my_deck_clicked():
	if %VBoxContainer.get_child_count() == 0:
		return
	$DeckSelect.show()
	deck_select_target = $MyDeck


func _on_cpu_deck_clicked():
	if %VBoxContainer.get_child_count() == 0:
		return
	$DeckSelect.show()
	deck_select_target = $CpuDeck


func _on_deck_select_gui_input(event):
	if (event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed):
		$DeckSelect.hide()
