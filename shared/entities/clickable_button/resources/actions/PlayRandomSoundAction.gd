class_name  PlayRandomSoundAction extends ButtonAction

@export var test_effects: Array[AudioStream] = []

func execute(_base: ClickableButton) -> void:
	GlobalSoundManager.play_sound_effect(test_effects.pick_random())