# Here is where the magic begins

# A little tool to ensure that it'll work in editor (we never use it in editor anyway)
@tool
extends ResourceFormatLoader

# Docs says that it needs a class_name in order to register it in ResourceLoader
# Who am I to judge the docs?
class_name PlainTextFormatLoader

# Preload to avoid problems with project.godot
const PlainTextClass = preload("res://addons/custom_resource/plain_text_resource.gd")

# Dude, look at the docs, I'm not going to explain each function... 
# Specially when they are self explainatory...
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["txt"])


# Ok, if custom resources were a thing this would be even useful.
# But is not.
# I don't know what is taking longer, Godot 4 or https://github.com/godotengine/godot/pull/48201
func _get_resource_type(path: String) -> String:
	# For now, the only thing that you need to know is that this thing serves as
	# a filter for your resource. You verify whatever you need on the file path
	# or even the file itself (with a File.load)
	# and you return "Resource" (or whatever you're working on) if you handle it.
	# Everything else ""
	var ext = path.get_extension().to_lower()
	if ext == "txt":
		return "Resource"
	
	return ""


# Ok, if custom resources were a thing this would be even useful.
# But is not. (again)
# You need to tell the editor if you handle __this__ type of class (wich is an string)
func _handles_type(typename: StringName) -> bool:
	# I'll give you a hand for custom resources... use this snipet and that's it ;)
	return ClassDB.is_parent_class(typename, "Resource")


# And this is the one that does the magic.
# Read your file, parse the data to your resource, and return the resource
# Is that easy!

# Even JSON can be accepted here, if you like that (I don't, but I'm not going to judge you)
func _load(path: String, original_path: String,use_sub_threads : bool,intcache_mode):
	var res := PlainTextClass.new()
	var file := FileAccess.open(path,FileAccess.READ)
	if not file:
		var err := FileAccess.get_open_error()
		push_error("For some reason, loading custom resource failed with error code: %s"%err)
		# You has to return the error constant
		return err
	res.text = file.get_as_text()
	file.close()
	# Everything went well, and you parsed your file data into your resource. Life is good, return it
	return res

