extends ClickableButton

@export var game_lobby_template: PackedScene
@export var transmit_click_position: bool = false
@export var is_connect_button: bool = false

var _current_ip: String = ""
var _current_player_name: String = ""

func _ready():
	if game_lobby_template == null:
		printerr("missing game lobby template")
		queue_free()

func ip_updated(ip: String):
	_current_ip = ip

func name_updated(player_name: String):
	_current_player_name = player_name

func _pressed():
	super()
	var instance := game_lobby_template.instantiate() as MultiplayerGameLobby
	instance.set_player_name(_current_player_name)
	instance.start_as_host()
	if is_connect_button:
		instance.set_connect_endpoint(_current_ip)
	
	if transmit_click_position:
		ScreenTransitionManager.transit_screen_by_node_with_position(instance, get_global_center_position())
		return
	ScreenTransitionManager.transit_screen_by_node(instance)
