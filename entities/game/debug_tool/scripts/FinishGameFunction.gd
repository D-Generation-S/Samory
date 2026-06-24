class_name FinishGame extends DebugFunctionality

func get_display_name() -> String:
	return "Finish Game"

func  execute_function(memory_game: MemoryGame) -> void:
	memory_game.show_game_end_screen()
