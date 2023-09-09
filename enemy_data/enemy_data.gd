extends Resource

class_name EnemyData


@export var name : String
@export var hp : int
@export var enemy_image : Texture

@export var deck_list : PackedInt32Array

@export var factory_script : GDScript

var factory : MechanicsData.ICardFactory :
	get:
		if not factory:
			factory = factory_script.new()
		return factory
		
