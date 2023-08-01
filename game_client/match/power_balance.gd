extends Control

class_name CombatPowerBalance

class Interface:
	var handle : CombatPowerBalance
	var reverse : bool
	
	func _init(cpb : CombatPowerBalance,r : bool):
		handle = cpb
		reverse = r

	func change_power(my_power : int,duration : float):
		if reverse:
			handle.change_rival_power(my_power,duration)
		else:
			handle.change_my_power(my_power,duration)


const MAGNIFICATION := 10.0
const border_table = [10,19,27,34,40,45,49,52,54,55]

@onready var power_balance_top = $PowerBalanceTop
@onready var power_balance_bottom = $PowerBalanceBottom

var _my_power : int = 0
var _rival_power : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	power_balance_top.split_offset = int(size.x / 2)
	power_balance_bottom.split_offset = int(size.x / 2)
	pass # Replace with function body.


func change_both_power(my_power : int,rival_power : int,duration : float):
	var situation = my_power - rival_power
	var border : float = 0.0
	
	if situation > 0:
		var index = mini(situation,10)
		border = border_table[index-1] * MAGNIFICATION
	elif situation < 0:
		var index = mini(-situation,10)
		border = -border_table[index-1] * MAGNIFICATION
	
	var offset : int = int(size.x / 2 - border)
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(power_balance_top,"split_offset",offset,duration)
	tween.tween_property(power_balance_bottom,"split_offset",offset,duration)
	_my_power = my_power
	_rival_power = rival_power
	

func change_my_power(my_power : int,duration : float):
	change_both_power(my_power,_rival_power,duration)

func change_rival_power(rival_power : int,duration : float):
	change_both_power(_my_power,rival_power,duration)
	
	
