extends Node2D

class_name SoundManager

@export var precreated_sound_managers: int = 5
@export_enum("Master", "sfx", "music") var audio_bus: String = "Master"

var sound_stream_node: Node2D
var players: int = 0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	sound_stream_node = Node2D.new()
	add_child(sound_stream_node)
	
	var listener: AudioListener2D = AudioListener2D.new()
	listener.make_current()
	add_child(listener)

	for i: int in precreated_sound_managers:
		sound_stream_node.add_child(create_new_audio_stream_player() )

func create_new_audio_stream_player() -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player.name = "player_" + str(players)
	player.bus = audio_bus
	players += 1
	return player

func play_sound_effect(sound: AudioStream, volume_db: float = 0) -> void:
	var free_audio_stream: AudioStreamPlayer2D = null
	for child: AudioStreamPlayer2D in sound_stream_node.get_children():
		if !child.playing:
			free_audio_stream = child
	if free_audio_stream == null:
		var node: AudioStreamPlayer2D = create_new_audio_stream_player()
		sound_stream_node.add_child(node)
		free_audio_stream = node

	free_audio_stream.volume_db = volume_db
	free_audio_stream.stream = sound
	free_audio_stream.play()

func stop_all_sounds() -> void:
	for child: AudioStreamPlayer2D in sound_stream_node.get_children():
		if child is AudioStreamPlayer2D and child.playing:
			child.stop()
