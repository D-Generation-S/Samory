@abstract
# Save file idea is based on https://youtu.be/yuvliTJ6ATA
class_name Save extends Resource

@export var last_write: float = -1.0
@export var last_game_version: String = "0.0.0"

func save(path: String) -> bool:
	self.last_write = Time.get_unix_time_from_system()
	self.last_game_version = ProjectSettings.get_setting("application/config/version")
	return ResourceSaver.save(self, path) == OK

static func _impl_load(path: String) -> Save:
	if not FileAccess.file_exists(path):
		return null
	var raw: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	var loaded_save: Save = raw as Save
	if loaded_save != null and loaded_save is Save:
		return loaded_save

	return null