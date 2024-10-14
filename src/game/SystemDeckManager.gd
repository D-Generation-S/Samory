extends Node2D

class_name SystemDeckManager


signal loading_system_decks()
signal loading_system_decks_done()

const CHECK_INTERVALL_SECONDS: float = 2
var elapsed_time = 0
var system_decks: Array[MemoryDeckResource] = []
var load_threads: Array[Thread] = []
var deck_loader: DeckLoader

func _ready():
	deck_loader = DeckLoader.new() as DeckLoader

func is_loading() -> bool:
	return load_threads.size() > 0

func get_system_decks() -> Array[MemoryDeckResource]:
	return system_decks

func reload_system_decks():
	if is_loading():
		return
	var decks = deck_loader.list_decks()
	if decks.size() == 0:
		loading_system_decks_done.emit()
		return
	loading_system_decks.emit()
	system_decks = []
	for deck in decks:
		load_threads.append(deck_loader.load_deck_async(deck))

func _process(delta):
	if is_loading():
		elapsed_time = elapsed_time + delta
		if elapsed_time < CHECK_INTERVALL_SECONDS:
			return
		elapsed_time = 0
		var loading_done = true
		for thread in load_threads:
			if thread.is_alive():
				loading_done = false
				break;
		if loading_done:
			for thread in load_threads:
				var data = thread.wait_to_finish() as MemoryDeckResource
				if data != null:
					system_decks.append(data)
			load_threads = []
			loading_system_decks_done.emit()
