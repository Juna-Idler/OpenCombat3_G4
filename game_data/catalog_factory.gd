
class_name CatalogFactory

var basic_catalog := CardCatalog.new()

var registered : Dictionary = {"Basic":basic_catalog}


func get_catalog(name : String) -> I_CardCatalog:
	return registered.get(name)


func register(name : String,catalog : I_CardCatalog):
	registered[name] = catalog

func delete(name : String):
	registered.erase(name)
	
