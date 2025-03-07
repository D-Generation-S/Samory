extends ClickableButton

@export var test_effects: Array[AudioStream] = []

func _pressed():
	super()
	var sound_index = randi() % test_effects.size()
	GlobalSoundManager.play_sound_effect(test_effects[sound_index])

