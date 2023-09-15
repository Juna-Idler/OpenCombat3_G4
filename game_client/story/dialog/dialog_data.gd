
class_name DialogData

class DialogUnit:
	var name : String
	var text : String
	var name_color : Color
	var text_color : Color
	
	func _init(n : String,t : String,nc : Color = Color.WHITE,tc : Color = Color.WHITE):
		name = n
		text = t
		name_color = nc
		text_color = tc
	

class SequencialScenario:
	var list : Array[DialogUnit]
	
	func _init(l : Array[DialogUnit]):
		list = l
	static func load_text(text : String) -> SequencialScenario:
		@warning_ignore("shadowed_variable")
		var list : Array[DialogUnit] = []
		var lines := text.split("\n")
		var main : String = ""
		var sub : String = ""
		for l in lines:
			if l.is_empty():
				continue
			if not l.begins_with("\t"):
				if not main.is_empty():
					list.append(DialogUnit.new(main,sub))
					main = ""
					sub = ""
				main = l
			else:
				sub += l.substr(1) + "\n"
		if not main.is_empty():
			list.append(DialogUnit.new(main,sub))
			main = ""
			sub = ""
		return SequencialScenario.new(list)


