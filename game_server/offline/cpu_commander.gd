
class_name ICpuCommander

class Player:
	var hand : PackedInt32Array
	var played : PackedInt32Array
	var discard : PackedInt32Array
	
	var stock_count : int
	var life : int
	var states : Dictionary
	
	func _init(h,p,d,s,l,st):
		hand = h
		played = p
		discard = d
		stock_count = s
		life = l
		states = st


func _get_commander_name()-> String:
	return ""

func _set_deck_list(_mydeck : PackedInt32Array,_rivaldeck : PackedInt32Array):
	return

func _first_select(_myhand : PackedInt32Array, _rivalhand : PackedInt32Array)-> int:
	return 0

func _combat_select(_myself : Player,_rival : Player)-> int:
	return 0

func _recover_select(_myself : Player,_rival : Player)-> int:
	return 0


class ZeroCommander extends ICpuCommander:
	func _get_commander_name()-> String:
		return "ZeroCommander"
		
