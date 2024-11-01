extends Node2D

signal song_changed(song: SongResource)

@export var audio_bus_name: String

## The number of tracks to rememver and not reuse
@export var tracks_to_skip: int = 0
@export var tracks: Array[SongResource] = []
@export var fade_step_size: float = 0.25
@export var seconds_used_for_fading: int = 5
@export_range(-100, 20) var disabled_db_value: float = -80
@export var target_db_value: float = 0

var last_tracks: Array[SongResource] = []

var playing_node: AudioStreamPlayer2D
var next_node: AudioStreamPlayer2D
var fading: bool = false
var switch_now: bool = false
var already_init: bool = false

var timer: Timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if tracks_to_skip > tracks.size():
		tracks_to_skip = tracks.size() - 2;

	if tracks_to_skip < 0:
		tracks_to_skip = 0

	timer = Timer.new()
	timer.timeout.connect(switch_song)
	add_child(timer)

func start_playing():
	if already_init:
		return
	already_init = true

	next_node = create_audio_stream()
	add_child(next_node)
	
	playing_node = create_audio_stream()
	add_child(playing_node)

	play_new_song(get_next_track())


func create_audio_stream() -> AudioStreamPlayer2D:
	var node = AudioStreamPlayer2D.new()
	node.bus = audio_bus_name
	return node

func get_valid_tracks() -> Array[SongResource]:
	var valid_tracks: Array[SongResource] = []

	if last_tracks.size() > tracks_to_skip:
		var counter = last_tracks.size() - tracks_to_skip
		for i in range(0, counter):
			last_tracks.pop_front()

	for track in tracks:
		if track.is_valid() and not last_tracks.has(track):
			valid_tracks.append(track)
	return valid_tracks
	
func play_new_song(song: SongResource):
	last_tracks.append(song)
	next_node.stream = song.song_data
	next_node.volume_db = disabled_db_value
	next_node.play()
	timer.wait_time = song.get_length() - 5
	timer.start()
	song_changed.emit(song)
	fading = true
	
func switch_song():
	var new_track = get_next_track()
	timer.wait_time = new_track.get_length() - seconds_used_for_fading
	timer.start()
	play_new_song(new_track)

func get_next_track() -> SongResource:
	var valid_tracks = get_valid_tracks()
	var index = randi() % valid_tracks.size()
	return valid_tracks[index]

func _process(_delta):
	if switch_now:
		next_node.volume_db = target_db_value
		playing_node.volume_db = disabled_db_value
		var new_active = next_node
		next_node = playing_node
		playing_node = new_active
		switch_now = false

	if not fading:
		return
	
	if next_node.volume_db >= target_db_value:
		next_node.volume_db = target_db_value
		playing_node.volume_db = disabled_db_value
		switch_now = true
		fading = false
	
	next_node.volume_db = next_node.volume_db + fade_step_size
	playing_node.volume_db = playing_node.volume_db - fade_step_size
	
func skip_song():
	timer.stop()
	switch_song()
