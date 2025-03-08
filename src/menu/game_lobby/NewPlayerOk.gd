extends ClickableButton

signal player_was_added(player: PlayerResource)

@export var player_name_field: LineEditValidation
@export var fields_for_validation: Array[LineEditValidation]

var is_valid: bool = false

func _ready():
	super()
	disabled = true

func _pressed():
	if !is_valid:
		return
	
	super()
	var player_name = player_name_field.text

	var return_player = PlayerResource.new()

	return_player.name = player_name
	return_player.score = 0
	return_player.id = -1

	player_was_added.emit(return_player)

func text_submitted(_text: String):
	validate()
	if is_valid:
		_pressed()

func invalid_data():
	disabled = true

func validate():
	var all_valid = true
	for field in fields_for_validation:
		if !field.is_valid():
			all_valid = false
			break
	disabled = !all_valid
	is_valid = all_valid
