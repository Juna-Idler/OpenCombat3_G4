extends Control

const SkillLine := preload("res://game_client/card/card_skill_line.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(card_name : String,
		c : CatalogData.CardColors,l : int,p : int,h : int,b : int,
		skills : Array[CatalogData.CardSkill],pict : Texture2D,opponent : bool = false):
	
	%LabelName.text = card_name
	$LabelPower.text = str(p)
	$LabelHit.text = str(h)
	$LabelBlock.text = str(b)
	$LabelLevel.text = str(l)
	$ColorRectFrame.color = CatalogData.RGB[c]
	$Power.color = CatalogData.RGB[c].darkened(0.3)
	$Hit.color = CatalogData.RGB[c].darkened(0.5)
	$Block.color = CatalogData.RGB[c].darkened(0.5)
	for line in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(line)
		line.queue_free()

	for s in skills:
		var line := SkillLine.instantiate()
		line.initialize(s,opponent)
		$VBoxContainer.add_child(line)
	$TextureRect.texture = pict
	
	if opponent:
		%LabelName.rotation_degrees = 180
		$LabelPower.rotation_degrees = 180
		$LabelHit.rotation_degrees = 180
		$LabelBlock.rotation_degrees = 180
		$LabelLevel.rotation_degrees = 180
	
	pass
