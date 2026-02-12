class_name OpenSystemFolder extends ButtonAction

## A path inside the godot user folder, for example "user://custom_decks/"
@export var user_path: String
@export var force_create_folder: bool = false

func _get_absolute_path() -> String:
	return ProjectSettings.globalize_path(user_path)

func execute(_base: ClickableButton) -> void:
	OS.shell_open(_get_absolute_path())

func can_execute() -> bool:
	if force_create_folder:
		DirAccess.make_dir_absolute(_get_absolute_path())
	if DirAccess.dir_exists_absolute(_get_absolute_path()):
		return true
	return false