extends HSlider

enum BusNames 
{
	Master,
	Effect,
	Music
}

signal volume_changed(bus_name: int, new_volume: float)

@export var bus_name: BusNames

var bus_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_id = AudioServer.get_bus_index(map_enum_to_name(bus_name))
	step = 0.001
	min_value = 0
	max_value = 1
	var volume: float = AudioServer.get_bus_volume_db(bus_id)
	value = db_to_linear(volume)
	connect("value_changed", _on_value_changed)

func map_enum_to_name(bus_name_to_match: BusNames) -> String:
	match bus_name_to_match:
		BusNames.Master:
			return "Master"
		BusNames.Effect:
			return "sfx"
		BusNames.Music:
			return "music"
	return "Master"

func map_local_enum_to_global(local: BusNames) -> int:
	match local:
		BusNames.Master:
			return BusType.Master
		BusNames.Effect:
			return BusType.Effect
		BusNames.Music:
			return BusType.Music
	return BusType.Master

func _on_value_changed(volume: float) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(volume))
	volume_changed.emit(map_local_enum_to_global(bus_name), volume)
	
func settings_loaded(settings: SettingsResource) -> void:
	match bus_name:
		BusNames.Master:
			value = settings.master_volume
		BusNames.Effect:
			value = settings.effect_volume
		BusNames.Music:
			value = settings.music_volume