class_name MultiplayerStartGame extends ClickableButton

signal start_game(position: Vector2)

@export var is_server_only: bool = false
var _deck_valid: bool = false

func _ready() -> void:
	super()
	if !is_server_only:
		return
	await get_tree().physics_frame
	if !multiplayer.is_server():
		queue_free()
		return
	_validate_button()

func players_updated() -> void:
	_validate_button()

func _pressed() -> void:
	_validate_button()
	if disabled:
		return
	start_game.emit(get_global_center_position())

func deck_changed(deck: MemoryDeckResource) -> void:
	_deck_valid = deck != null and deck.built_in
	_validate_button()

func _validate_button() -> void:
	var valid: bool = multiplayer.get_peers().size() >= 1
	if valid:
		enable_button()
		return

	disable_button()
	
