class_name SelectAiPlayer extends Control

signal dialog_closed()
signal ai_added(ai: AiDifficultyResource)

func close_dialog() -> void:
	dialog_closed.emit()
	queue_free()

func confirm_ai_player(ai: AiDifficultyResource) -> void:
	if ai == null:
		return
	ai_added.emit(ai)