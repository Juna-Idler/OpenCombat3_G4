extends HBoxContainer

const CardDetailSkill := preload("res://game_client/card/card_detail_skill.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func initialize(cd : CatalogData.CardData,
		c : CatalogData.CardColors,l : int,p : int,h : int,b : int,
		skills : Array[CatalogData.CardSkill],pict : Texture2D):
	for child in $ScrollContainer/VBoxContainer.get_children():
		$ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	
	$CardFront.initialize(cd.name,c,l,p,h,b,skills,pict)
	for s in skills:
		var label : RichTextLabel = CardDetailSkill.instantiate()
		label.text = s.title + "\n" + s.data.text
		$ScrollContainer/VBoxContainer.add_child(label)
	
	
