class_name EffectPlayer extends Node

@export var audio_files: Array[AudioStream] = []

@export_group("Volume")
@export var volume_modifier_bd: float = 0

@export_group("Pitch effect")
@export var enable_pitch_effect: bool
@export var min_pitch: float = 0.8
@export var max_pitch: float = 1.2

func _ready() -> void:
	if audio_files.size() == 0:
		push_error("Missing audio file")	
		queue_free()

func play_effect() -> void:
	var pitch: float = 1.0
	if enable_pitch_effect:
		pitch = randf_range(min_pitch, max_pitch)
	GlobalSoundManager.play_sound_effect(audio_files.pick_random(), volume_modifier_bd, pitch)