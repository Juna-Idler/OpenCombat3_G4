
class_name DialogData

enum CommandType {
	MESSAGE,
	
}

class Command:
	var command : CommandType
	
	static func create(main : String,sub : String) -> Command:
		if main.begins_with(" "):
			return CommandMessage.new(main.substr(1),sub)
		assert(false)
		return null

class CommandMessage extends Command:
	var name : String
	var text : String
	var name_color : Color
	var text_color : Color
	
	func _init(n : String,t : String,nc : Color = Color.WHITE,tc : Color = Color.WHITE):
		name = n
		text = t
		name_color = nc
		text_color = tc


class Scene:
	var list : Array[Command]
	
	func _init(l : Array[Command]):
		list = l
		
	static func create(text : String) -> Scene:
		@warning_ignore("shadowed_variable")
		var list : Array[Command] = []
		var lines := text.split("\n")
		var main : String = ""
		var sub : String = ""
		for l in lines:
			if l.is_empty():
				continue
			if not l.begins_with("\t"):
				if not main.is_empty():
					list.append(Command.create(main,sub))
					main = ""
					sub = ""
				main = l
			else:
				sub += l.substr(1) + "\n"
		if not main.is_empty():
			list.append(Command.create(main,sub))
			main = ""
			sub = ""
		return Scene.new(list)

class Options:
	var list : PackedStringArray
	func _init(l : PackedStringArray):
		list = l
	static func create(text : String) -> Options:
		var lines := text.split("\n")
		@warning_ignore("shadowed_variable")
		var list : PackedStringArray = []
		for l in lines:
			if l.is_empty():
				continue
			list.append(l)
		return Options.new(list)

class ScenarioPackage:
	var scene : Dictionary
	var options : Dictionary
	
	func _init(s : Dictionary,o : Dictionary):
		scene = s
		options = o
	
	func get_first_scene() -> Scene:
		return null if scene.is_empty() else scene.values()[0]
	

	static func load_text(text : String) -> ScenarioPackage:
		@warning_ignore("shadowed_variable")
		var scene : Dictionary = {}
		@warning_ignore("shadowed_variable")
		var options : Dictionary = {}
		
		var mode : String
		var name : String
		var contents : String
		
		var lines := text.split("\n")
		for l in lines:
			if l.is_empty():
				continue
			if l.begins_with("@"):
				if not name.is_empty():
					match mode:
						"Scene":
							scene[name] = Scene.create(contents)
						"Options":
							options[name] = Options.create(contents)
					mode = ""
					name = ""
					contents = ""
				if l.to_lower().begins_with("@scene "):
					mode = "Scene"
					name = l.split(" ")[1]
				elif l.to_lower().begins_with(("@options ")):
					mode = "Options"
					name = l.split(" ")[1]
			else:
				contents += l + "\n"
		if not name.is_empty():
			match mode:
				"Scene":
					scene[name] = Scene.create(contents)
				"Options":
					options[name] = Options.create(contents)
		return ScenarioPackage.new(scene,options)


