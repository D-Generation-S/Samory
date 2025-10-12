extends ClickableButton

@export var test_effects: Array[AudioStream] = []
@export var hover_sound: AudioStream

func _ready() -> void:
	if hover_sound != null:	
		mouse_entered.connect(_on_focused)
		focus_entered.connect(_on_focused)

func _pressed() -> void:
	super()
	var sound_index: int = randi() % test_effects.size()
	GlobalSoundManager.play_sound_effect(test_effects[sound_index])

func _on_focused() -> void:
	GlobalSoundManager.play_sound_effect(hover_sound)
