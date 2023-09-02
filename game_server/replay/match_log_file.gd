
class_name MatchLogFile

const FILE_VERSION = "Ver.first_time"


static func save_log(path : String,log_data : MatchLog) -> bool:
	var dir_path := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	var save_dic = {
		"version":FILE_VERSION,
		"log":log_data.serialize()
	}
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dic))
		file.close()
		return true
	return false

static func load_log(path : String) -> MatchLog:
	var file := FileAccess.open(path,FileAccess.READ)
	if not file:
		return null
	var text := file.get_as_text()
	var json = JSON.parse_string(text)
	file.close()
	if not json:
		return null
		
	if typeof(json) != TYPE_DICTIONARY:
		return null
	if not json.has("version") or json["version"] != FILE_VERSION:
		return null
	if not json.has("log"):
		return null
		
	var ml := MatchLog.new()
	ml.deserialize(json["log"])
	return ml
	

static func load_directory(directory_path : String) -> Array[MatchLog]:
	var dir := DirAccess.open(directory_path)
	var files := dir.get_files()
	var list : Array[MatchLog] = []
	for f in files:
		var path := directory_path.path_join(f)
		var log_data := MatchLogFile.load_log(path)
		if log_data:
			list.append(log_data)
	return list

