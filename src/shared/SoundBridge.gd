extends Node2D

class_name SoundBridge

signal play_sound_effect(stream: AudioStream)
signal stop_sound_effects()

@export var button_click_sound: AudioStream
@export var button_hover_sound: AudioStream
@export var toggle_sound: AudioStream
@export var text_input_sound: AudioStream

func _ready() -> void:
	connect("play_sound_effect", GlobalSoundManager.play_sound_effect)
	connect("stop_sound_effects", GlobalSoundManager.stop_all_sounds)

func play_sound(stream: AudioStream) -> void:
	if stream == null:
		return
	play_sound_effect.emit(stream)

func stop_sound() -> void:
	stop_sound_effects.emit()

func play_button_click() -> void:
	play_sound(button_click_sound)

func play_button_hover() -> void:
	play_sound(button_hover_sound)

func play_text_input() -> void:
	play_sound(text_input_sound)

func play_toggle_sound() -> void:
	play_sound(toggle_sound)

