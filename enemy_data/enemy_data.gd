
class_name EnemyData

var name : String
var ruby_name : String
var text : String
var hp : int
var enemy_image : Texture

var deck_list : PackedInt32Array

var catalog : I_CardCatalog
var factory : MechanicsData.ICardFactory

func _init(n,rn,t,health,i,list,c,f):
	name = n
	ruby_name = rn
	text = t
	hp = health
	enemy_image = i
	deck_list = list
	catalog = c
	factory = f
	
