extends CanvasGroup

signal ready_for_destruction()

@export var possible_effects: Array[DisolveEffectResource] = []
@export var progress_per_tick: float = 0.2

var root_node: CardTemplate = null
var progress: float  = 0
var destroy_now: bool = false

var loot_table: LootTable
var effect_multiplier: float = 1

	 

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_parent()
	loot_table = LootTable.new()
	for effect in possible_effects:
		loot_table.add_to_table(effect, effect.rarity)

func _process(delta):
	if !destroy_now:
		return
	progress = progress + (progress_per_tick * effect_multiplier) * delta
	progress = clampf(progress, 0.0 , 1.0)
	material.set_shader_parameter("progress", progress)

	if progress == 1:
		ready_for_destruction.emit()

func animate_destruction():
	destroy_now = true;
	var loot = loot_table.get_loot() as DisolveEffectResource;
	material = loot.effect_material.duplicate()
	effect_multiplier = loot.effect_speed_multiplier
	var effect_sound = loot.remove_sound
	GlobalSoundManager.play_sound_effect(effect_sound)

