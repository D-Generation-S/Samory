class_name GameBroadcast extends Node

signal server_information_received(data: ServerInformation)

@export var is_receiver: bool = false
@export var broadcast_interval: float = 1
@export var broadcast_port: int = 8001

var _broadcast_timer: Timer = null
var _udp: PacketPeerUDP = null

func _ready() -> void:
	_udp = PacketPeerUDP.new()
	tree_exiting.connect(_cleanup)
	await get_tree().physics_frame
	if not is_receiver and not multiplayer.is_server():
		queue_free()
		return
	if not is_receiver:
		_udp.set_broadcast_enabled(true)
		_udp.set_dest_address("255.255.255.255", broadcast_port)
		process_mode = Node.PROCESS_MODE_DISABLED

		_broadcast_timer = Timer.new()
		_broadcast_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		_broadcast_timer.wait_time = broadcast_interval
		_broadcast_timer.autostart = true
		_broadcast_timer.one_shot = false
		_broadcast_timer.timeout.connect(func()-> void: _send_broadcast(_build_package_data()))
		add_child(_broadcast_timer)
		return
	_udp.bind(broadcast_port)

func _cleanup() -> void:
	_udp.close()
	_udp = null

func _build_package_data() -> Dictionary:
	var return_data: ServerInformation = ServerInformation.new(get_network_ip(), ProjectSettings.get_setting("application/config/version"))
	return return_data.to_dictionary()

func get_network_ip() -> String:
	var ip_address: String = "127.0.0.1"
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)

	return ip_address

	

func _send_broadcast(data: Dictionary) -> void:	
	var raw_data: String = JSON.stringify(data)
	_udp.put_packet(raw_data.to_utf8_buffer())
	

func _process(_delta: float) -> void:
	if _udp.get_available_packet_count() > 0:
		var array_bytes: PackedByteArray = _udp.get_packet()
		var data: String = array_bytes.get_string_from_utf8()
		var parsed_data: ServerInformation = ServerInformation.from_dictionary(JSON.parse_string(data))
		server_information_received.emit(parsed_data)
