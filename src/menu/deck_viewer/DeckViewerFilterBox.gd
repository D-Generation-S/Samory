extends LineEdit

func _ready() -> void:
	text_changed.connect(text_was_changed)

func text_was_changed(_new_text: String) -> void:
	GlobalSoundBridge.play_text_input()

func toggle_enabled(on: bool) -> void:
	editable = on

func enable() -> void:
	toggle_enabled(true)

func disable() -> void:
	text = ""
	toggle_enabled(false)
