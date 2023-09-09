
class_name CatalogData


enum CardColors {NOCOLOR = 0,RED = 1,GREEN = 2,BLUE = 3}
const RGB : Array[Color] = [Color(0.5,0.5,0.5),Color(1,0,0),Color(0,0.7,0),Color(0,0,1)]

enum ColorCondition {
	NOCONDITION = 0,
	COLOR_BITS = 3,
	VS_FLAG = 4,
	VS_RED = 5,
	VS_GREEN = 6,
	VS_BLUE = 7,
	LINK_FLAG = 8,
	LINK_RED = 9,
	LINK_GREEN = 10,
	LINK_BLUE = 11,
}
enum ParamType {
	VOID = 0,		
	INTEGER = 1,	# int
	STATS = 2,		# [p:int,h:int,b:int]
	COLOR = 3,		# int as CardColors
}

class CardData:
	var id : int
	var name : String
	var ruby_name : String

	var color : CardColors
	var level : int
	var power : int
	var hit : int
	var block : int
	var skills : Array[CardSkill]
	var abilities : Array[AbilityData]
	var text : String
	var image : String 


	func _init(i : int,n : String,rn : String,
			c : CardColors,l : int,p : int,h : int,b : int,
			s : Array[CardSkill],a : Array[AbilityData],t : String,im : String):
		id = i
		name = n
		ruby_name = rn
		color = c
		level = l
		power= p
		hit = h
		block = b
		
		skills = s
		abilities = a
		text = t
		image = im


	static func copy(dest : CardData, src : CardData):
		dest.id = src.id
		dest.name = src.name
		dest.ruby_name = src.ruby_name
		dest.color = src.color
		dest.level = src.level
		dest.power = src.power
		dest.hit = src.hit
		dest.block = src.block
		dest.skills = src.skills
		dest.text = src.text
		dest.image = src.image


class SkillData:
	var id : int
	var name : String
	var ruby_name : String
	var param_type : PackedInt32Array # of ParamType
	var param_name : PackedStringArray
	var enchants : Array[EnchantmentData]
	var text : String
	
	func _init(i:int,n:String,rn:String,pt:PackedInt32Array,pn:PackedStringArray,
			e:Array[EnchantmentData],t:String):
		id = i
		name = n
		ruby_name = rn
		param_type = pt
		param_name = pn
		enchants = e
		text = t

class CardSkill:
	var index : int
	var data : SkillData
	var condition : int
	var parameter : Array
	var title : String
	var text : String
	
	func _init(i:int,sd:SkillData,c:int,p : Array,t : String,txt : String):
		index = i
		data = sd
		condition = c
		parameter = p
		title = t
		text = txt

	func test_condition(rival_color : int,link_color : int) -> bool :
		if condition & ColorCondition.VS_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == rival_color
		if condition & ColorCondition.LINK_FLAG:
			return (condition & ColorCondition.COLOR_BITS) == link_color
		if condition == ColorCondition.NOCONDITION:
			return true
		return false

class AbilityData:
	var id : int
	var name : String
	var ruby_name : String
	var enchants : Array[EnchantmentData]
	var text : String
	
	func _init(i:int,n:String,rn:String,e:Array[EnchantmentData],txt:String):
		id = i
		name = n
		ruby_name = rn
		enchants = e
		text = txt


class EnchantmentData:
	var id : int
	var name : String
	var ruby_name : String
	var param_type : PackedInt32Array # of ParamType
	var param_name : PackedStringArray
	var text : String
	
	func _init(i:int,n:String,rn:String,pt:PackedInt32Array,pn:PackedStringArray,t:String):
		id = i
		name = n
		ruby_name = rn
		param_type = pt
		param_name = pn
		text = t


class ParameterName:
	var type : ParamType
	var names : PackedStringArray

	func _init(t:ParamType,n:String):
		type = t
		names = n.split(",")
		if names.size() == 1 and names[0] == "":
			names = []

