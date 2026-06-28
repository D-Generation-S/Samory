extends CanvasLayer

signal decks_loading()
signal deck_loading_done(decks: Array[MemoryDeckResource])
signal scene_ready()

var _is_initial_load: bool = true

func load_decks() -> void:
	decks_loading.emit()

func loading_done(decks: Array[MemoryDeckResource]) -> void:
	deck_loading_done.emit(decks)

func cards_preloaded() -> void:
	scene_ready.emit()

func scene_is_ready() -> void:
	if _is_initial_load:
		await get_tree().physics_frame
		_is_initial_load = false
	scene_ready.emit()