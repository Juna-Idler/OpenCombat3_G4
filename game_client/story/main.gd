
extends Node

var story_data

@onready var dialog : DialogWindow = %Dialog
@onready var battle = $Battle


class Controller extends I_StoryController:
	var dialog : DialogWindow
	var battle : StoryBattle
	
	func _init(d : DialogWindow,b : StoryBattle):
		dialog = d
		battle = b
	
	func _dialog_clear() -> void:
		dialog.clear()
		
	func _play_cut_async(cut : DialogData.Cut) -> bool:
		dialog.show()
		return await dialog.play_cut_async(cut)

	func _show_options_async(option_names : PackedStringArray) -> int:
		return await dialog.show_options_async(option_names)

	func _battle_start_async(player_name : String,player_deck : PackedInt32Array,player_hand : int,
		enemy_name : String,battle_script : I_BattleScript) -> int:
		dialog.hide()
		var enemy_data := EnemyDataFactory.create(enemy_name)
		enemy_data.hp = 3
#		var factory := PlayerCardFactory.new(card_catalog)
#		battle.initialize(player_name,Global.card_catalog,player_deck,player_hand,enemy_data,battle_script)
		var deck = [1,2,4,3,3,3,3,3]
		battle.initialize(player_name,deck,player_hand,false,
				enemy_data.catalog,enemy_data.factory,enemy_data,battle_script)
		await battle.battle_finished
		battle.terminalize()
		return battle.battle_result

	func _fade_in_dialog_async(duration : float):
		var tween := dialog.create_tween()
		dialog.show()
		dialog.modulate.a = 0.0
		tween.tween_property(dialog,"modulate:a",1.0,duration)
		await tween.finished
	func _fade_out_dialog_async(duration : float):
		var tween := dialog.create_tween()
		tween.tween_property(dialog,"modulate:a",0.0,duration)
		await tween.finished
		dialog.hide()
		dialog.clear()
		
	func _fade_in_battle(_duration : float):
		pass
	func _fade_out_battle(_duration : float):
		pass


func _ready():
	var controller := Controller.new(dialog,battle)
	const Tutorial = preload("res://game_client/tutorial/story_script.gd")
	const Tutorial1_Battle = preload("res://game_client/tutorial/t1_battle_script.gd")
	const tutorial1_battle_scenario = preload("res://game_client/tutorial/1.txt")
	var script := Tutorial.new(Tutorial1_Battle.new(controller,tutorial1_battle_scenario.text))
#	var text_resource := load("res://game_client/story/test.txt")
#	var script := TestScript.new(text_resource.text)
	start_async(script)


	
func start_async(story_script : I_StoryScript) -> bool:
	return await story_script._start(Controller.new(dialog,battle))
	



