extends ClickableButton

@export var game_lobby_template: PackedScene
@export var transmit_click_position: bool = false
@export var is_connect_button: bool = false

func _ready() -> void:
	if game_lobby_template == null:
		printerr("missing game lobby template")
		queue_free()

func _pressed() -> void:
	super()
	var instance: MultiplayerGameLobby = game_lobby_template.instantiate() as MultiplayerGameLobby
	instance.start_as_host()
	if transmit_click_position:
		ScreenTransitionManager.transit_screen_by_node_with_position(instance, get_global_center_position())
		return
	ScreenTransitionManager.transit_screen_by_node(instance)