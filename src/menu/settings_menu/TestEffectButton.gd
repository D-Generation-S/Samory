extends ClickableButton

@export var test_effects: Array[AudioStream] = []
@export var hover_sound: AudioStream

func _ready():
	if hover_sound != null:	
		mouse_entered.connect(_on_focused)
		focus_entered.connect(_on_focused)

func _pressed():
	super()
	var sound_index = randi() % test_effects.size()
	GlobalSoundManager.play_sound_effect(test_effects[sound_index])

func _on_focused():
	GlobalSoundManager.play_sound_effect(hover_sound)
