class_name ServerEntry extends Control

signal name_changed(new_name: String)
signal version_changed(new_version: String)
signal pressed(server_name: String)

var _data: ServerInformation = null

func set_data_set(data: ServerInformation) -> void:
	_data = data
	name_changed.emit(_data.get_ip())
	version_changed.emit("(%s)" % data.get_version())

func was_clicked() -> void:
	pressed.emit(_data.get_ip())

func remove_requested(id: int) -> void:
	if _data.get_unique_id() == id:
		queue_free()