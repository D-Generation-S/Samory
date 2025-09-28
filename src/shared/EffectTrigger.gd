class_name EffectTrigger extends Node

@export var effect_pool: Array[AudioStream] = []
@export_range(-80, 20, 0.5) var volume: float = 0

var  _active: bool = true

func _ready():
	if effect_pool.size() == 0:
		queue_free()

func trigger_random_effect():
	if not _active:
		return
	var effect = effect_pool.pick_random()
	GlobalSoundManager.play_sound_effect(effect, volume)

func toggle_state(new_state: bool):
	_active = new_state