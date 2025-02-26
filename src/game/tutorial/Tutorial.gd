extends Control

signal pause_game()
signal continue_game()

@export var tutorial_window_scene: PackedScene = null

var tutorial_scene: TutorialWindow = null
var settings: SettingsResource = null
var tutorial_settings: TutorialResource = null

# Called when the node enters the tutorial_scene tree for the first time.
func _ready():
	settings = SettingsRepository.load_settings() as SettingsResource
	tutorial_settings = settings.tutorial as TutorialResource
	if tutorial_window_scene == null or tutorial_settings == null:
		printerr("Missing template for tutorial window, or settings not loaded")
		queue_free()
		return
	if is_tutorial_done():
		queue_free()
		return
	tutorial_scene = tutorial_window_scene.instantiate() as TutorialWindow
	tutorial_scene.window_closed.connect(unpause)
	tutorial_scene.abort_tutorial.connect(abort_tutorial)
	add_child(tutorial_scene)

func is_tutorial_done() -> bool:
	if tutorial_settings.tutorial_aborted:
		return true
	return tutorial_settings.player_turn \
			and tutorial_settings.first_round_done \
			and tutorial_settings.first_matching_card_found \
			and tutorial_settings.first_card_turned

func player_turn():
	if tutorial_settings.player_turn:
		return
	tutorial_settings.player_turn = true
	open_tutorial_window("PLAYER_TURN", "PLAYER_TURN_BODY", true)
	pass

func first_card_turned():
	if tutorial_settings.first_card_turned:
		return
	tutorial_settings.first_card_turned = true
	open_tutorial_window("FIRST_CARD_TURNED", "FIRST_CARD_TURNED_BODY", false)
	pass

func first_matching_card():
	if tutorial_settings.first_matching_card_found:
		return
	tutorial_settings.first_matching_card_found = true
	open_tutorial_window("FIRST_MATCHING_CARD", "FIRST_MATCHING_CARD_BODY", false)
	pass

func first_round_end():
	if tutorial_settings.first_round_done:
		return
	tutorial_settings.first_round_done = true
	open_tutorial_window("FIRST_ROUND_END", "FIRST_ROUND_END_BODY", false)
	pass

func open_tutorial_window(title: String, body: String, allow_abort: bool = false):
	pause_game.emit()
	mouse_filter = MOUSE_FILTER_STOP
	tutorial_scene.show_window(title, body, allow_abort)
	save_settings()

func save_settings():
	settings.tutorial = tutorial_settings
	SettingsRepository.save_settings(settings)

func unpause():
	mouse_filter = MOUSE_FILTER_IGNORE
	continue_game.emit()

func abort_tutorial():
	tutorial_settings.tutorial_aborted = true
	save_settings()
	unpause()
	queue_free()

func tutorial_completed():
	tutorial_scene.close()
	unpause()
	queue_free()
