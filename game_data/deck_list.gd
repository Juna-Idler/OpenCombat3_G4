
class_name DeckList


var file_path : String

var list : Array[DeckData] = []
var select : int = 0

var _catalog_factory : CatalogFactory

func _init(path : String,cf : CatalogFactory):
	file_path = path
	_catalog_factory = cf
	load_deck_list()

func clamp_select() -> int:
	select = clampi(select,0,list.size()-1)
	return select




func save_deck_list():
	if select >= list.size():
		select = list.size()-1;
	if select < 0:
		select = 0

	var dic := {
		"select":select,
		"list":list.map(func(v : DeckData):return v.serialize())
	}
	var json := JSON.stringify(dic)
	var f = FileAccess.open(file_path,FileAccess.WRITE)
	f.store_string(json)
	f.close()
	
	
func load_deck_list() -> bool:
	if not FileAccess.file_exists(file_path):
		return false
		
	var f = FileAccess.open(file_path,FileAccess.READ)
	var json := f.get_as_text()
	f.close()

	var dic = JSON.parse_string(json)
	if not dic is Dictionary:
		return false
	select = dic["select"]
	list.assign(dic["list"].map(func(v):return DeckData.deserialize(v,_catalog_factory)))
	
	return true
	
