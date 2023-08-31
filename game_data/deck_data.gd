
class_name DeckData

var name : String
var catalog : I_CardCatalog
var cards : PackedInt32Array

func _init(n : String,c : I_CardCatalog, cs : PackedInt32Array):
	name = n
	catalog = c
	cards = cs

func equal(other : DeckData) -> bool:
	return name == other.name and catalog == other.catalog and cards == other.cards

func get_cards_count() -> int:
	return cards.size()

func get_total_cost() -> int:
	var cost : int = 0
	for i in cards:
		var c := catalog._get_card_data(i)
		cost += c.level
	return cost

func get_level_count() -> PackedInt32Array:
	var level : PackedInt32Array = [0,0,0,0]
	for i in cards:
		var c := catalog._get_card_data(i)
		level[c.level] += 1
	return level

func get_color_count() -> PackedInt32Array:
	var color : PackedInt32Array = [0,0,0,0]
	for i in cards:
		var c := catalog._get_card_data(i)
		color[c.color] += 1
	return color


func serialize() -> Dictionary:
	return {
		"name":name,
		"catalog":catalog._get_catalog_name(),
		"cards":cards,
	}

static func deserialize(dic : Dictionary,catalog_factory : CatalogFactory) -> DeckData:
	if not dic.has("name") or not dic.has("catalog") or not dic.has("cards"):
		return null
#	if not dic["name"] is String or not dic["catalog"] is String or not dic["cards"] is Array:
#		return null
	
	return DeckData.new(dic["name"],catalog_factory.get_catalog(dic["catalog"]),dic["cards"])


