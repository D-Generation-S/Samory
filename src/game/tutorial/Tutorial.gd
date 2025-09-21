extends Node

signal tutorial_requested(scene: Control)

@export var tutorial_window_scene: PackedScene = null
@export var available_tutorials: Array[TutorialInformation] = []

var tutorial_scene: TutorialWindow = null
var settings: SettingsResource = null

func _ready():
	settings = SettingsRepository.load_settings() as SettingsResource
	if tutorial_window_scene == null or settings == null:
		printerr("Missing template for tutorial window, or settings not loaded")
		queue_free()
		return
	if is_tutorial_done():
		queue_free()
		return

func trigger_tutorial(tutorial_type: Enums.Tutorial_State):
	if settings.tutorial_aborted:
		return
	var selected_tutorial: TutorialInformation = null
	for tutorial in available_tutorials:
		if tutorial.tutorial_type == tutorial_type:
			selected_tutorial = tutorial
			break
	if selected_tutorial == null:
		return
	var setting_key: String = Enums.Tutorial_State.keys()[selected_tutorial.tutorial_type]
	if settings.tutorials.has(setting_key) and settings.tutorials[setting_key]:
		return
	settings.tutorials[setting_key] = true
	open_tutorial_window_by_information(selected_tutorial)

func is_tutorial_done() -> bool:
	if settings.tutorial_aborted:
		return true
	var all_true: bool = true
	for key in Enums.Tutorial_State.keys():
		if key == Enums.Tutorial_State.keys()[0]:
			continue
		if !settings.tutorials.has(key) or !settings.tutorials[key]:
			all_true = false
			break
	return all_true

func open_tutorial_window_by_information(tutorial: TutorialInformation):
	open_tutorial_window(tutorial.title, tutorial.body, tutorial.allow_abort)

func open_tutorial_window(title: String, body: String, allow_abort: bool = false):
	tutorial_scene = tutorial_window_scene.instantiate() as TutorialWindow
	tutorial_scene.abort_tutorial.connect(abort_tutorial)
	tutorial_requested.emit(tutorial_scene)
	tutorial_scene.show_window(title, body, allow_abort)
	save_settings()

func abort_tutorial():
	settings.tutorial_aborted = true
	save_settings()

func save_settings():
	SettingsRepository.save_settings(settings)
