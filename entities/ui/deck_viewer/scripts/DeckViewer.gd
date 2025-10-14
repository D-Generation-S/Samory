extends CanvasLayer

signal decks_loading()
signal deck_loading_done(decks: Array[MemoryDeckResource])
signal scene_ready()

func _ready() -> void:
	load_decks()

func load_decks() -> void:
	decks_loading.emit()

func loading_done(decks: Array[MemoryDeckResource]) -> void:
	deck_loading_done.emit(decks)

func cards_preloaded() -> void:
	scene_ready.emit()

func scene_is_ready() -> void:
	scene_ready.emit()