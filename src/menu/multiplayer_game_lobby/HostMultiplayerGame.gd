extends ClickableButton

@export var game_lobby_template: PackedScene
@export var transmit_click_position: bool = false
@export var is_connect_button: bool = false

var _current_ip: String = ""
var _current_player_name: String = ""

func _ready() -> void:
	if game_lobby_template == null:
		printerr("missing game lobby template")
		queue_free()

func ip_updated(ip: String) -> void:
	_current_ip = ip

func name_updated(player_name: String) -> void:
	_current_player_name = player_name

func _pressed() -> void:
	super()
	var instance: MultiplayerGameLobby= game_lobby_template.instantiate() as MultiplayerGameLobby
	var settings: SettingsResource = SettingsRepository.load_settings()
	SettingsRepository.save_settings(settings)
	instance.set_player_name(_current_player_name)
	
	if is_connect_button:
		instance.set_connect_endpoint(_current_ip)
		SettingsRepository.save_current_settings()
	else:
		instance.start_as_host()
	
	if transmit_click_position:
		ScreenTransitionManager.transit_screen_by_node_with_position(instance, get_global_center_position())
		return
	ScreenTransitionManager.transit_screen_by_node(instance)
