
class_name CatalogFactory

var basic_catalog := CardCatalog.new()


func get_catalog(name : String) -> I_CardCatalog:
	if name == "Basic":
		return basic_catalog
	
	return null

