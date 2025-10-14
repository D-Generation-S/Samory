extends VBoxContainer

signal address_requested(address: String)
signal connection_triggered()

@export var server_entry_template: PackedScene = null
@export var second_until_refresh: int = 4
@export var timer_target_node: Node

var known_servers: Array[ServerInformation]

var _current_unique_id: int = 0
var _check_timer: Timer = null

func _ready() -> void:
	_check_timer = Timer.new()
	_check_timer.wait_time = 1
	_check_timer.autostart = true
	_check_timer.one_shot = false
	_check_timer.timeout.connect(_check_entries)
	timer_target_node.add_child(_check_timer)

func server_found(data: ServerInformation) -> void:
	var index: int = known_servers.find_custom(func(server: ServerInformation) -> bool: return server.is_identical(data))
	if index == -1:
		data.update_date_time()
		data.set_unique_id(_current_unique_id)
		known_servers.append(data)
		create_new_server(data)
		_current_unique_id = _current_unique_id + 1
		return
	var entry: ServerInformation = known_servers[index]
	entry.update_date_time()
	
func _check_entries() -> void:
	for entry: ServerInformation in known_servers:
		if entry.get_age_in_seconds() > second_until_refresh:
			remove_server(entry.get_unique_id())

func create_new_server(data: ServerInformation) -> void:
	var entry: ServerEntry = server_entry_template.instantiate() as ServerEntry
	entry.pressed.connect(_handle_server_click)
	entry.set_data_set(data)
	add_child(entry)

func _handle_server_click(server_name: String) -> void:
	address_requested.emit(server_name)
	connection_triggered.emit()

func remove_server(id: int) -> void:
	for child: ServerEntry in get_children():
		child.remove_requested(id)
	var index: int = known_servers.find_custom(func(server: ServerInformation) -> bool: return server.get_unique_id() == id)
	if index == -1:
		return
	known_servers.remove_at(index)
