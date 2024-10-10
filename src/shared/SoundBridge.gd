extends Node2D

class_name SoundBridge

signal play_sound_effect(stream: AudioStream)
signal stop_sound_effects()

@export var sound_manager: SoundManager
@export var button_click_sound: AudioStream
@export var button_hover_sound: AudioStream
@export var text_input_sound: AudioStream

func play_sound(stream: AudioStream):
	if stream == null:
		return
	play_sound_effect.emit(stream)

func stop_sound():
	stop_sound_effects.emit()

func play_button_click():
	play_sound(button_click_sound)

func play_button_hover():
	play_sound(button_hover_sound)

func play_text_input():
	play_sound(text_input_sound)

