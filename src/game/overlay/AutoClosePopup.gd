extends PopupWindow

signal settings_loaded(settings: SettingsResource)

var auto_close_round: bool = false
var auto_complete_time: float = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	var settings = SettingsRepository.load_settings()
	auto_close_round = settings.auto_close_round
	auto_complete_time = settings.close_round_after_seconds
	settings_loaded.emit(settings)

func auto_complete_state_changed(new_state: bool):
	auto_close_round = new_state

func auto_complete_time_changed(new_time: float):
	auto_complete_time = new_time

func close_now():
	var settings = SettingsRepository.load_settings()
	settings.auto_close_round =  auto_close_round
	settings.close_round_after_seconds = auto_complete_time
	SettingsRepository.save_settings(settings)
	visible = false
	queue_free()
	popup_closed.emit()
