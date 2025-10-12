extends ClickableButton

signal player_was_added(player: PlayerResource)

@export var player_name_field: LineEditValidation
@export var fields_for_validation: Array[LineEditValidation]

var is_valid: bool = false

func _ready() -> void:
	super()
	disabled = true

func _pressed() -> void:
	if !is_valid:
		return
	
	super()
	var player_name: String = player_name_field.text

	var return_player: PlayerResource = PlayerResource.new()

	return_player.name = player_name
	return_player.score = 0
	return_player.id = -1

	player_was_added.emit(return_player)

func text_submitted(_text: String) -> void:
	validate()
	if is_valid:
		_pressed()

func invalid_data() -> void:
	disabled = true

func validate() -> void:
	var all_valid: bool = true
	for field: LineEditValidation in fields_for_validation:
		if !field.is_valid():
			all_valid = false
			break
	disabled = !all_valid
	is_valid = all_valid
