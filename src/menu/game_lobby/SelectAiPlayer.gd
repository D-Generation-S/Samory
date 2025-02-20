class_name SelectAiPlayer extends CanvasLayer

signal dialog_closed()
signal ai_added(ai: AiDifficultyResource)

func close_dialog():
	dialog_closed.emit()
	queue_free()

func confirm_ai_player(ai: AiDifficultyResource):
	if ai == null:
		return
	ai_added.emit(ai)