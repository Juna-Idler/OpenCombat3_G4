
class_name PlayerCardFactory

extends MechanicsData.ICardFactory


const skill_behaviors : Array = [
	null,
	SkillProcessor.Reinforce,
	SkillProcessor.Pierce,
	SkillProcessor.Charge,
	SkillProcessor.Isolate,
	SkillProcessor.Absorb,
	SkillProcessor.BlowAway,
	SkillProcessor.Attract,
	SkillProcessor.Recycle,
	SkillProcessor.AngerBlow,
]
const enchant_behaviors : Array = [
	null,
	EnchantmentProcessor.Reinforce,
	EnchantmentProcessor.AngerCounter,
]

const ability_behaviors : Array = [
	null,
	AbilityProcessor.AngerCounter,
]


var _card_catalog : CardCatalog

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog

func _create(iid : int,data_id : int) -> MechanicsData.Card:
	var card_data := _card_catalog._get_card_data(data_id)
	var skills : Array[MechanicsData.ISkill] = []
	for s in card_data.skills:
		skills.append(_create_skill(s))
	return MechanicsData.Card.new(iid,card_data,skills)
	
func _create_skill(skill : CatalogData.CardSkill) -> MechanicsData.ISkill:
	return skill_behaviors[skill.data.id].new(skill)
	
func _create_enchant(match_id:int,data_id : int,param : Array,
		attached : MechanicsData.IPlayer,opponent : MechanicsData.IPlayer) -> MechanicsData.IEnchantment:
	return enchant_behaviors[data_id].new(match_id,param,attached,opponent)

func _ability_behavior(data_id : int,
		myself : MechanicsData.IPlayer,
		rival : MechanicsData.IPlayer) -> Array[IGameServer.EffectFragment]:
	return ability_behaviors[data_id].effect(myself,rival)
