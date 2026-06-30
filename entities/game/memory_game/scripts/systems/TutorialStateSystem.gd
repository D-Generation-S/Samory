class_name TutorialStateSystem extends Node

@export var tutorial_window_scene: PackedScene = null
@export var available_tutorials: Array[TutorialInformation] = []

#signal trigger_tutorial(tutorial_state: Enums.Tutorial_State)
signal tutorial_requested(scene: PopupWindow)

var _current_player: PlayerResource = null
var _tutorial_scene: TutorialWindow = null
var _settings: SettingsResource = null

func _ready() -> void:
	_settings = SettingsRepository.load_settings() as SettingsResource
	if tutorial_window_scene == null or _settings == null:
		printerr("Missing template for tutorial window, or _settings not loaded")
		queue_free()
		return
	if is_tutorial_done():
		queue_free()
		return

func state_changed(new_state: GameEnum.State) -> void:
	if _is_ai_player():
		return
	if new_state == GameEnum.State.TURN_START:
		trigger_tutorial(Enums.Tutorial_State.PLAYER_TURN)
	if new_state == GameEnum.State.PREPARE_TURN_END:
		trigger_tutorial(Enums.Tutorial_State.PLAYER_TURN_END)
	pass

func card_triggered() -> void:
	if _is_ai_player():
		return
	trigger_tutorial(Enums.Tutorial_State.PLAYER_TURNED_CARD)

func matching_card_found() -> void:
	if _is_ai_player():
		return
	trigger_tutorial(Enums.Tutorial_State.PLAYER_FOUND_MATCHING_PAIR)

func player_changed(new_player: PlayerResource) -> void:
	_current_player = new_player

func _is_ai_player() -> bool:
	return _current_player == null or _current_player.is_ai()

func trigger_tutorial(tutorial_type: Enums.Tutorial_State)-> void:
	if _settings.tutorial_aborted:
		return
	var selected_tutorial: TutorialInformation = null
	for tutorial: TutorialInformation in available_tutorials:
		if tutorial.tutorial_type == tutorial_type:
			selected_tutorial = tutorial
			break
	if selected_tutorial == null:
		return
	var setting_key: String = Enums.Tutorial_State.keys()[selected_tutorial.tutorial_type]
	if _settings.tutorials.has(setting_key) and _settings.tutorials[setting_key]:
		return
	_settings.tutorials[setting_key] = true
	open_tutorial_window_by_information(selected_tutorial)

func is_tutorial_done() -> bool:
	if _settings.tutorial_aborted:
		return true
	var all_true: bool = true
	for key: String in Enums.Tutorial_State.keys():
		if key == Enums.Tutorial_State.keys()[0]:
			continue
		if !_settings.tutorials.has(key) or !_settings.tutorials[key]:
			all_true = false
			break
	return all_true

func open_tutorial_window_by_information(tutorial: TutorialInformation) -> void:
	open_tutorial_window(tutorial.title, tutorial.body, tutorial.allow_abort)

func open_tutorial_window(title: String, body: String, allow_abort: bool = false) -> void:
	_tutorial_scene = tutorial_window_scene.instantiate() as TutorialWindow
	_tutorial_scene.abort_tutorial.connect(abort_tutorial)
	tutorial_requested.emit(_tutorial_scene)
	_tutorial_scene.show_window(title, body, allow_abort)
	_save_settings()

func abort_tutorial() -> void:
	_settings.tutorial_aborted = true
	_save_settings()

func _save_settings() -> void:
	SettingsRepository.save_settings(_settings)
