extends LineEdit

func _ready():
	text_changed.connect(text_was_changed)

func text_was_changed(_new_text: String):
	GlobalSoundBridge.play_text_input()

func toggle_enabled(on: bool):
	editable = on

func enable():
	toggle_enabled(true)

func disable():
	text = ""
	toggle_enabled(false)
