class_name AnimatedText extends RichTextLabel

signal text_getting_animated()
signal is_multi_text()
signal current_text_displayed()
signal no_text_left()
signal animation_state_changed(new_state: bool)

@export var letter_place_sound: AudioStream = null
@export var written_end_sound: AudioStream = null
@export var sound_db_change: float = 0
@export var time_per_letter: float = 0.02;


var tween: Tween = null
var text_queue: Array[String] = []

var animating: bool = false
var should_animate: bool = true

var _initial_text: String = ""
var _last_value: float = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = ""
	add_animated_text(_initial_text)
	if animating:
		visible_characters = 0

func set_initial_text(new_text: String) -> void:
	_initial_text = new_text
	text = _initial_text

func toggle_animation(on: bool) -> void:
	should_animate = on

func add_animated_text(new_text: String) -> void:
	if new_text == "":
		return
	var translated: String = tr(new_text)
	text_queue.append(translated)
	if animating:
		is_multi_text.emit()
		return
	display_animated_text(text_queue.pop_front())

func display_animated_text(text_to_display: String) -> void:
	_last_value = -1
	text = text_to_display
	if !should_animate:
		text_was_set()
		return
	animating = true
	visible_characters = 0
	text_getting_animated.emit()
	animation_state_changed.emit(true)
	tween = create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.tween_method(animation_step, 0, text.length(), time_per_letter * text.length())
	tween.finished.connect(text_was_set)

func animation_step(value: float) -> void:
	if _last_value == value:
		return
	_last_value = value
	var letters_to_show: int = int(value)
	play_letter_sound()
		
	visible_characters = letters_to_show
	if letters_to_show >= text.length():
		visible_characters = -1

func play_letter_sound() -> void:
	GlobalSoundManager.play_sound_effect(letter_place_sound, sound_db_change)

func roll_in_next_text() -> void:
	if text_queue.size() == 0:
		no_text_left.emit()
		animation_state_changed.emit(false)
		return
	display_animated_text(text_queue.pop_front())

func text_was_set() -> void:
	animating = false
	current_text_displayed.emit()
	if text_queue.size() == 0:
		no_text_left.emit()
		animation_state_changed.emit(false)
	if should_animate:
		GlobalSoundManager.play_sound_effect(written_end_sound, sound_db_change)

