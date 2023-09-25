
class_name I_BattleScript

class Data:
	var round_count : int
	var phase : IGameServer.Phase

	func _init(rc : int,p : IGameServer.Phase):
		round_count = rc
		phase = p


func _start_event() -> void:
	@warning_ignore("redundant_await")
	await 0
	return

func _hand_selected_event(_data : Data) -> bool:
	@warning_ignore("redundant_await")
	return await true
	
func _performed_event(_data : Data) -> bool:
	@warning_ignore("redundant_await")
	return await true
	
func _end_event() -> void:
	@warning_ignore("redundant_await")
	await 0
	return

