extends Node2D

class_name SoundManager

@export var precreated_sound_managers: int = 5
@export_enum("Master", "sfx", "music") var audio_bus: String = "Master"

var sound_stream_node: Node2D


func _ready():
	sound_stream_node = Node2D.new()
	add_child(sound_stream_node)
	
	var listener = AudioListener2D.new()
	listener.make_current()
	add_child(listener)

	for i in range(precreated_sound_managers):
		sound_stream_node.add_child(create_new_audio_stream_player() )

func create_new_audio_stream_player() -> AudioStreamPlayer2D:
	var player = AudioStreamPlayer2D.new()
	player.bus = audio_bus
	return player

func play_sound_effect(sound: AudioStream):
	var free_audio_stream = null
	for child in sound_stream_node.get_children():
		if child is AudioStreamPlayer2D and !child.playing:
			free_audio_stream = child
	if free_audio_stream == null:
		var node = create_new_audio_stream_player()
		sound_stream_node.add_child(node)
		free_audio_stream = node

	free_audio_stream.stream = sound
	free_audio_stream.play()

func stop_all_sounds():
	for child in sound_stream_node.get_children():
		if child is AudioStreamPlayer2D and child.playing:
			child.stop()
