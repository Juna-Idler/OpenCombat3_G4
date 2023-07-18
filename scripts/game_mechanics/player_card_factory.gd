
class_name PlayerCardFactory

extends MechanicsData.ICardFactory


const skill_behaviors : Array = [
	null,
#	SkillProcessor.Reinforce,
#	SkillProcessor.Pierce,
#	SkillProcessor.Charge,
#	SkillProcessor.Isolate,
#	SkillProcessor.Absorb,
#	SkillProcessor.BlowAway,
#	SkillProcessor.Attract,
]
const state_behaviors : Array = [
	null,
	StateProcessor.Reinforce,
]

var _card_catalog : CardCatalog

func _init(card_catalog : CardCatalog):
	_card_catalog = card_catalog

func _create(iid : int,data_id : int) -> Card:
	var card_data := _card_catalog._get_card_data(data_id)
	var skills := []
	for s in card_data.skills:
		skills.append(_create_skill(s))
	return Card.new(iid,card_data,skills)
	
func _create_skill(skill : CatalogData.CardSkill) -> ISkill:
	return skill_behaviors[skill.data.id].new(skill)
	
func _create_state(match_id:int,data_id : int,param : Array,attached : IPlayer,opponent : IPlayer) -> IState:
	return state_behaviors[data_id].new(match_id,param,attached,opponent)
