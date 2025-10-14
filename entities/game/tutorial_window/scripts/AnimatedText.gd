class_name AnimatedText extends RichTextLabel

signal text_getting_animated()
signal is_multi_text()
signal current_text_displayed()
signal no_text_left()

@export var letter_place_sound: AudioStream = null
@export var written_end_sound: AudioStream = null
@export var sound_db_change: float = 0
@export var time_per_letter: float = 0.02;


var tween: Tween = null
var text_queue: Array[String] = []
var target_text: String = ""

var animating: bool = false
var should_animate: bool = true
var last_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = ""

func toggle_animation(on: bool) -> void:
	should_animate = on

func add_animated_text(new_text: String) -> void:
	var translated: String = tr(new_text)
	text_queue.append(translated)
	if animating:
		print("multi")
		is_multi_text.emit()
		return
	display_animated_text(text_queue.pop_front())

func display_animated_text(text_to_display: String) -> void:
	if !should_animate:
		text = text_to_display
		text_was_set()
		return
	animating = true
	text_getting_animated.emit()
	target_text = text_to_display
	last_index = 0
	tween = create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.tween_method(animation_step, 0, target_text.length(), time_per_letter * target_text.length())
	tween.finished.connect(text_was_set)

func animation_step(value: float) -> void:
	var letters_to_show: int = int(value)
	if last_index < letters_to_show:
		last_index = letters_to_show
		play_letter_sound()
	text = target_text.substr(0, letters_to_show)

func play_letter_sound() -> void:
	GlobalSoundManager.play_sound_effect(letter_place_sound, sound_db_change)

func roll_in_next_text() -> void:
	if text_queue.size() == 0:
		no_text_left.emit()
		return
	display_animated_text(text_queue.pop_front())

func text_was_set() -> void:
	animating = false
	current_text_displayed.emit()
	if text_queue.size() == 0:
		no_text_left.emit()
	if should_animate:
		GlobalSoundManager.play_sound_effect(written_end_sound, sound_db_change)

