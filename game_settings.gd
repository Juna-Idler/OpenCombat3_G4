
class_name GameSettings

const path = "user://game_settings.cfg"

var config := ConfigFile.new()


var player_name : String = "Unknown"

#var online_servers := [
#	"wss://opencombat3.onrender.com",
#	"https://127.0.0.1:8080"
#]
#var server_index : int = 0


func load_config():
	if config.load(path) != OK:
		return
	
	for i in AudioServer.bus_count:
		_load_sound(AudioServer.get_bus_name(i))
	player_name = config.get_value("Player","name")
	
func save_config():
	for i in AudioServer.bus_count:
		_save_sound(AudioServer.get_bus_name(i))
	config.set_value("Player","name",player_name)
	config.save(path)


func _load_sound(bus_name:String):
	var volume = config.get_value("Sound_"+bus_name,"volume")
	var mute = config.get_value("Sound_"+bus_name,"mute")
	var idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(idx,-volume)
	AudioServer.set_bus_mute(idx,mute)

func _save_sound(bus_name:String):
	var idx = AudioServer.get_bus_index(bus_name)
	var volume = -AudioServer.get_bus_volume_db(idx)
	var mute = AudioServer.is_bus_mute(idx)
	config.set_value("Sound_"+bus_name,"volume",volume)
	config.set_value("Sound_"+bus_name,"mute",mute)
	
