extends Node2D

signal song_changed(song: SongResource)

@export var audio_bus_name: String

@export var tracks_to_skip: int = 0
@export var tracks: Array[SongResource] = []
@export var initial_song_fade_duration: float = 1;
@export var song_fade_duration: int = 2
@export_range(-100, 20) var disabled_db_value: float = -80
@export var target_db_value: float = 10

var last_tracks: Array[SongResource] = []

var already_init: bool = false
var fade_duration: float = 0 

# This timer will be started on each song and after it completes it will trigger a song switch
# Therefor it will subtract the transition time from the song duration.
var track_change_time: Timer = null
var sound_emitter_node: Node2D

func _ready() -> void:
	fade_duration = initial_song_fade_duration
	if tracks_to_skip > tracks.size():
		tracks_to_skip = tracks.size() - 2;

	if tracks_to_skip < 0:
		tracks_to_skip = 0

	track_change_time = Timer.new()
	track_change_time.timeout.connect(switch_song)
	add_child(track_change_time)
	sound_emitter_node = Node2D.new()
	add_child(sound_emitter_node)

func start_playing() -> void:
	if already_init:
		return
	already_init = true

	play_new_song(get_next_track())

func _get_unused_audio_node() -> AudioStreamPlayer2D:
	for audio_stream: AudioStreamPlayer2D in sound_emitter_node.get_children():
		if !audio_stream.playing:
			return audio_stream

	var new_audio_stream: AudioStreamPlayer2D = _create_audio_stream()
	sound_emitter_node.add_child(new_audio_stream)
	return new_audio_stream

func _get_active_audio_nodes() -> Array[AudioStreamPlayer2D]:
	var audio_streams: Array[AudioStreamPlayer2D] = []
	for audio_stream: AudioStreamPlayer2D in sound_emitter_node.get_children():
		if audio_stream is AudioStreamPlayer2D:
			if audio_stream.playing:
				audio_streams.append(audio_stream)

	return audio_streams
			 

func _create_audio_stream() -> AudioStreamPlayer2D:
	var node: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	node.bus = audio_bus_name
	return node

func get_valid_tracks() -> Array[SongResource]:
	var valid_tracks: Array[SongResource] = []

	if last_tracks.size() > tracks_to_skip:
		var counter: int = last_tracks.size() - tracks_to_skip
		for i: int in counter:
			last_tracks.pop_front()

	for track: SongResource in tracks:
		if track.is_valid() and not last_tracks.has(track):
			valid_tracks.append(track)
	return valid_tracks
	
func play_new_song(song: SongResource) -> void:
	last_tracks.append(song)

	for active_audio_stream: AudioStreamPlayer2D in _get_active_audio_nodes():
		if active_audio_stream is AudioStreamPlayer2D:
			var tween_disable_audio: Tween = create_tween()
			tween_disable_audio.tween_property(active_audio_stream, "volume_db", disabled_db_value, fade_duration);


	var new_audio_manager: AudioStreamPlayer2D = _get_unused_audio_node()
	new_audio_manager.stream = song.song_data
	new_audio_manager.volume_db = disabled_db_value
	new_audio_manager.play()

	var tween_new_song_stream: Tween = create_tween()
	tween_new_song_stream.tween_property(new_audio_manager, "volume_db", target_db_value, fade_duration);
	tween_new_song_stream.finished.connect(func() -> void:
		fade_duration = song_fade_duration
	)

	track_change_time.wait_time = song.get_length() - fade_duration
	track_change_time.start()
	song_changed.emit(song)

func cleanup() -> void:
	var inactive_streams: Array[AudioStreamPlayer2D] = []
	for audio_stream: AudioStreamPlayer2D in sound_emitter_node.get_children():
		if !audio_stream.playing:
			inactive_streams.append(audio_stream)

	if inactive_streams.size() > 1:
		var first: bool = true
		for stream: AudioStreamPlayer2D in inactive_streams:
			if stream is AudioStreamPlayer2D:
				if first:
					continue
				stream.queue_free()

func switch_song() -> void:
	var new_track: SongResource = get_next_track()
	track_change_time.wait_time = new_track.get_length() - fade_duration
	track_change_time.start()
	play_new_song(new_track)

func get_next_track() -> SongResource:
	return get_valid_tracks().pick_random()
	
func skip_song() -> void:
	track_change_time.stop()
	switch_song()