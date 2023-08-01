extends ScrollContainer



var effect_opponent : bool
var fragment_opponent : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func append_round(round : int):
	"ラウンド{round}"
	$VBoxContainer
	pass

func append_timing(timing : I_MatchPlayer.EffectTiming):
	match timing:
		I_MatchPlayer.EffectTiming.INITIAL:
			"デッキ効果"
			pass
		I_MatchPlayer.EffectTiming.START:
			"開始時効果"
			pass
		I_MatchPlayer.EffectTiming.BEFORE:
			"交戦前効果"
			pass
		I_MatchPlayer.EffectTiming.MOMENT:
			"交戦時効果"
			pass
		I_MatchPlayer.EffectTiming.AFTER:
			"交戦後効果"
			pass
		I_MatchPlayer.EffectTiming.END:
			"終了時効果"
			pass
	pass

func append_combat_start(my_card : String,rival_card : String):
	"戦闘フェイズ"
	"自分のカード{my_card}"
	"相手のカード{rival_card}"
	pass

func append_combat_result_effect():
	effect_opponent = false
	"交戦結果"
	pass
	
func append_recovery_result_effect():
	effect_opponent = false
	"回復結果"
	pass

func append_effect_system(opponent : bool):
	effect_opponent = opponent
	"(自分|相手)の"
	"システム効果"
	pass

func append_effect_skill(title : String,opponent : bool):
	effect_opponent = opponent
	"スキル:{1}の効果"
	pass

func append_effect_enchant(title : String,opponent : bool):
	effect_opponent = opponent
	"エンチャント:{1}の効果"
	pass

func append_effect_ability(title : String,opponent : bool):
	effect_opponent = opponent
	"アビリティの効果"
	pass

func append_fragment_damage(unblocked_damage : int,blocked_damage : int,opponent : bool):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)に{1}ダメージ/{2}ブロック"
	pass
	
func append_fragment_initiative():
	pass
func append_fragment_combat_stats(p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)の戦闘カードに{p}/{h}/{b}"
	pass
func append_fragment_card_stats(card : String,p,h,b,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)の「{card}」に{p}/{h}/{b}"
	pass
	
func append_fragment_draw(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)は「{card}」を手札に加えた"
	
	pass
func append_fragment_discard(card : String,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)は「{card}」を捨てた"
	pass
func append_fragment_bounce(card : String,position,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)は「{card}」をデッキの{pos}に戻した"
	pass

func append_fragment_create_enchant(title,opponent_soucer,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)は「{title}」を得た"
	"(自分|相手)は「{title}」を受けた"
	pass
func append_fragment_update_enchant(title,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)の「{title}」が更新された"
	pass
func append_fragment_delete_enchant(title,expired,opponent):
	fragment_opponent = effect_opponent != opponent
	"(自分|相手)の「{title}」は消滅した"
	"(自分|相手)の「{title}」は除去された"
	pass

func append_fragment_create_card():
	pass


func append_passive(title,opponent):
	var passive_opponent : bool = fragment_opponent != opponent
	"パッシブ:(自分|相手)の「{title}」が変動"
	
