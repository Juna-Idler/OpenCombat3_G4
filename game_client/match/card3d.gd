extends Node3D

class_name Card3D

enum CardLocation {
	STOCK,
	HAND,
	COMBAT,
	PLAYED,
	DISCARD,
}

signal input_event(card : Card3D,camera : Camera3D, event : InputEvent, position : Vector3)

var tween : Tween	#個別にキャンセル可能にするための固有Tween


var id_in_deck : int

var location : CardLocation

var card_name : String

var color : CatalogData.CardColors
var level : int
var power : int
var hit : int
var block : int

var skills : Array[CatalogData.CardSkill]

var picture : Texture2D


func initialize(id : int,cn : String,
		c : CatalogData.CardColors,l : int,p : int,h : int,b : int,
		sk : Array[CatalogData.CardSkill],pict : Texture2D,opponent : bool = false):
	id_in_deck = id
	location = CardLocation.STOCK
	
	card_name = cn
	color = c
	level = l
	power = p
	hit = h
	block = b
	skills = sk
	picture = pict
	
	$SubViewport/CardFront.initialize(card_name,c,l,p,h,b,sk,pict,opponent)
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func update_card_stats(p:int,h:int,b:int):
	power = p
	hit = h
	block = b
	$SubViewport/CardFront.update_stats(power,hit,block)
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func set_albedo_color(c : Color):
	var material : StandardMaterial3D = $MeshInstance3D.material_override
	material.albedo_color = c


func set_ray_pickable(enable : bool):
	$Area3D.input_ray_pickable = enable

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween()
	tween.kill()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_area_3d_mouse_entered():
#	$MeshInstance3D.material_override.albedo_color = Color(1,0,0)
	pass # Replace with function body.


func _on_area_3d_mouse_exited():
#	$MeshInstance3D.material_override.albedo_color = Color(1,1,1)
	pass # Replace with function body.


func _on_area_3d_input_event(camera : Camera3D, event : InputEvent, hit_position : Vector3, _normal : Vector3, _shape_idx : int):
	input_event.emit(self,camera,event,hit_position)
#	print(hit_position,event.position,normal,event)

