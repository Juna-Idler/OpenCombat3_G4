@tool
extends ResourceFormatSaver
class_name PlainTextFormatSaver

# Preload to avoid problems with project.godot
const PlainTextClass = preload("res://addons/custom_resource/plain_text_resource.gd")


func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["txt"])


# Here you see if that resource is the type you need.
# Multiple resources can inherith from the same class
# Even they can modify the structure of the class or be pretty similar to it
# So you verify if that resource is the one you need here, and if it's not
# You let other ResourceFormatSaver deal with it.
func _recognize(resource: Resource) -> bool:
	# Cast instead of using "is" keyword in case is a subclass
	resource = resource as PlainTextClass
	
	if resource:
		return true
	
	return false


# Magic tricks
# Magic tricks
# Don't you love magic tricks?

# Here you write the file you want to save, and save it to disk too.
# For text is pretty trivial.
# Binary files, custom formats and complex things are done here.
func _save(resource: Resource, path: String, flags: int) -> Error:
	var file := FileAccess.open(path,FileAccess.WRITE)
	if not file :
		var err := FileAccess.get_open_error()
		printerr('Can\'t write file: "%s"! code: %d.' % [path, err])
		return err
	file.store_string(resource.get("text"))
	file.close()
	return OK
