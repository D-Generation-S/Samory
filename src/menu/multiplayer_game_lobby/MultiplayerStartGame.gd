class_name MultiplayerStartGame extends MultiplayerButton

signal start_game(position: Vector2)

var _deck_valid: bool = false

func _ready() -> void:
	super()
	_validate_button()

func players_updated() -> void:
	_validate_button()

func _pressed() -> void:
	super()
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
	