@tool
extends Resource
class_name PlainTextResource

# This is our resource, I'll expose the text property
# That property is just an string, we don't need anything special here.

var _text := ""
@export_multiline var text = "":
	get:
		return _text
	set(v):
		_text = v
		emit_changed()

# Q: Wait, I need a setter?
# A: Yes, you MUST tell the editor that you changed the resource somehow
#    If you forgot to do it, the resource will not be saved. Godot things.
