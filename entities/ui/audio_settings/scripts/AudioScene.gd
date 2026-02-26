extends PanelContainer

signal audio_bus_changed(bus_name: int, new_volume: float)

func change_audio_bus(bus_name: int, new_volume: float) -> void:
	audio_bus_changed.emit(bus_name, new_volume)