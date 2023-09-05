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


func _ready():
	pass
#	initialize()

func _process(_delta):
	pass

func _initialize(changer : SceneChanger,_param : Array):
	_scene_changer = changer
	pass
	
func _fade_in_finished():
	pass
	
func _terminalize():
	pass
	
