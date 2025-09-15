extends CanvasGroup

signal ready_for_destruction()

@export var possible_effects: Array[DissolveEffectResource] = []
# The seconds the destroy animation should be played
@export var time_to_vanish: float = 1.0

var root_node: CardTemplate = null
var destroy_now: bool = false

var loot_table: LootTable
var effect_multiplier: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_parent()
	loot_table = LootTable.new()
	for effect in possible_effects:
		loot_table.add_to_table(effect, effect.rarity)

func update_progress(value: float):
	material.set_shader_parameter("progress", value)

func animate_destruction():
	destroy_now = true
	var loot = loot_table.get_loot() as DissolveEffectResource
	material = loot.effect_material.duplicate()
	effect_multiplier = loot.effect_speed_multiplier
	var tween = create_tween()
	tween.bind_node(self)
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): ready_for_destruction.emit())
	tween.tween_method(update_progress, 0.0, 1.0, time_to_vanish)
	var effect_sound = loot.remove_sound
	GlobalSoundManager.play_sound_effect(effect_sound)

