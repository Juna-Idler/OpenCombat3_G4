extends Node3D

class_name Card3D


signal input_event(card : Card3D,camera : Camera3D, event : InputEvent, position : Vector3)

var tween : Tween	#個別にキャンセル可能にするための固有Tween


var id_in_deck : int

var location : int

var card_name : String

var color : int
var level : int
var power : int
var hit : int
var block : int

var skills : Array # of MatchEffect.IEffect

var picture


func set_ray_pickable(enable : bool):
	$Area3D.input_ray_pickable = enable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_mouse_entered():
	$MeshInstance3D.material_override.albedo_color = Color(1,0,0)
	pass # Replace with function body.


func _on_area_3d_mouse_exited():
	$MeshInstance3D.material_override.albedo_color = Color(1,1,1)
	pass # Replace with function body.


func _on_area_3d_input_event(camera : Camera3D, event : InputEvent, hit_position : Vector3, _normal : Vector3, _shape_idx : int):
	input_event.emit(self,camera,event,hit_position)
#	print(hit_position,event.position,normal,event)

