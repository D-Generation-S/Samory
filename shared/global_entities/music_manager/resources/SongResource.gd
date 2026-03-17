class_name SongResource extends Resource

@export_group("Meta Data")
@export var song_name: String
@export var interpret: String

@export_group("Song Data")
@export var song_data: AudioStream
@export var db_volume_change: float = 0


func is_valid() -> bool:
	return song_name != "" and interpret != "" and song_data != null

func get_length() -> float:
	return song_data.get_length()