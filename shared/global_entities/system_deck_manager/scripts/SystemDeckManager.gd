extends Node2D

class_name SystemDeckManager

signal loading_system_decks()
signal loading_system_decks_done()

const CHECK_INTERVAL_SECONDS: float = 2
var elapsed_time: float = 0
var system_decks: Array[MemoryDeckResource] = []
var deck_loader: DeckLoader

func _ready() -> void:
	deck_loader = DeckLoader.new() as DeckLoader

func clear_system_decks() -> void:
	system_decks = []

func get_system_decks() -> Array[MemoryDeckResource]:
	return system_decks

func reload_system_decks() -> void:
	loading_system_decks.emit()
	var decks: Array[String] = deck_loader.list_decks()
	system_decks = []
	var custom_decks: Array[MemoryDeckResource] = await deck_loader.load_custom_decks()
	system_decks.append_array(custom_decks)
	for deck: String in decks:
		var loaded_deck: MemoryDeckResource = await deck_loader.load_deck(deck)
		custom_decks.append(loaded_deck)

	loading_system_decks_done.emit()
