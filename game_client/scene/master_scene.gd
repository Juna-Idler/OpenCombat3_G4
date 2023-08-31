extends Node

class_name MasterScene

var scene_changer : SceneChanger

func _ready():
	var sf = %SceneFader
#	var ci = sf as CanvasItem
	scene_changer = SceneChanger.new(self,sf,$TitleScene)
	$TitleScene._initialize(scene_changer,[])
	%SceneFader.hide()
	pass


