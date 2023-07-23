
class_name DeckData

var name : String
var cards : PackedInt32Array #of int (card id)
var key_cards : PackedInt32Array #of int (card id)

func _init(d_name : String, d_cards : PackedInt32Array, k_cards : PackedInt32Array):
	cards = d_cards
	name = d_name
	key_cards = k_cards

func equal(other : DeckData) -> bool:
	if name != other.name or cards.size() != other.cards.size()\
			or key_cards.size() != other.key_cards.size():
		return false
	for i in cards.size():
		if cards[i] != other.cards[i]:
			return false
	for i in key_cards.size():
		if key_cards[i] != other.key_cards[i]:
			return false
	return true

class DeckFace:
	var name : String
	var key_cards : PackedInt32Array #of int (card id)
	var cards_count : int
	var total_cost : int
	var level : PackedInt32Array
	var color : PackedInt32Array
	
	func _init(n:String,kc : PackedInt32Array,
			count:int,cost:int,
			l:PackedInt32Array,c:PackedInt32Array):
		name = n
		key_cards = kc
		cards_count = count
		total_cost = cost
		level = l
		color = c

func get_deck_face(catalog : CardCatalog) -> DeckFace:
	var cost := 0
	var rgb := [0,0,0,0]
	var level := [0,0,0,0]
	for i in cards:
		var c := catalog._get_card_data(i) as CatalogData.CardData
		rgb[c.color] += 1
		level[c.level] += 1
		cost += c.level
	return DeckFace.new(name,key_cards,cards.size(),cost,level,rgb)

