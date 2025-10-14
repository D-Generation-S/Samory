class_name SongResource extends Resource

@export var song_name: String
@export var interpret: String
@export var song_data: AudioStream

func is_valid() -> bool:
	return song_name != "" and interpret != "" and song_data != null

func get_length() -> float:
	return song_data.get_length()