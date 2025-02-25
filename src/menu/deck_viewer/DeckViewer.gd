extends CanvasLayer

signal decks_loading()
signal deck_loading_done(decks: Array[MemoryDeckResource])
signal scene_ready()

func _ready():
	load_decks()

func load_decks():
	decks_loading.emit()

func loading_done(decks: Array[MemoryDeckResource]):
	deck_loading_done.emit(decks)

func cards_preloaded():
	scene_ready.emit()

func scene_is_ready():
	scene_ready.emit()