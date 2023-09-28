
class_name I_StoryScript


func _start_async(_controller : I_StoryController) -> bool:
	@warning_ignore("redundant_await")
	return await true


