extends Node2D

class_name LoadingScreen

signal play_sound(stream: AudioStream)

@export var screen_message: Label
@export var sound_effect: AudioStream

var game_manager: GameManager
var elapsed_time: float = 0
var effect_length: float = 1000000

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager = get_tree().root.get_child(0)
	effect_length = sound_effect.get_length()
	connect("play_sound", game_manager.play_sound_effect)
	elapsed_time = effect_length
	screen_message.text = ""

func _process(delta):
	if elapsed_time > effect_length:
		play_sound.emit(sound_effect)
		elapsed_time = elapsed_time - effect_length
	elapsed_time = elapsed_time + delta

func set_screen_message(new_text: String):
	screen_message.text = new_text
