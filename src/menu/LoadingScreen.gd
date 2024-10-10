extends Node2D

class_name LoadingScreen

@export var screen_message: Label
@export var static_label: Label
@export var sound_effect: AudioStream
@export var play_effects: bool = true

var game_manager: GameManager
var elapsed_time: float = 0
var effect_length: float = 1000000

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_tree().root.get_child(0)
	effect_length = sound_effect.get_length()
	elapsed_time = effect_length
	screen_message.text = ""

func _process(delta):
	if elapsed_time > effect_length and play_effects:
		game_manager.sound_bridge.play_sound(sound_effect)
		elapsed_time = elapsed_time - effect_length
	elapsed_time = elapsed_time + delta

func set_screen_message(new_text: String, remove_default_label:bool = false):
	screen_message.text = new_text
	if remove_default_label:
		static_label.visible = false

