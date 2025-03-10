extends ClickableButton

var current_ai: AiDifficultyResource = null
signal player_was_selected(new_ai: AiDifficultyResource)
signal closing()

func _pressed():
	if current_ai == null:
		return
	super()

	player_was_selected.emit(current_ai)
	closing.emit()

func ai_changed(new_ai: AiDifficultyResource):
	current_ai = new_ai