class_name ListOrphanNodes extends DebugFunctionality

func get_display_name() -> String:
	return "List Orphans"

func execute_function(memory_game: MemoryGame) -> void:
	memory_game.print_orphan_nodes()
