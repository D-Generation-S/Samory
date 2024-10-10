extends ClickableButton

signal player_was_added(player: PlayerResource)

@export var player_name_field: LineEditValidation
@export var player_age_field: LineEditValidation
@export var fields_for_validation: Array[LineEditValidation]

var is_valid: bool = false

func _ready():
	disabled = true

func _pressed():
	if !is_valid:
		return
	
	var player_name = player_name_field.text
	var age = int(player_age_field.text)

	var return_player = PlayerResource.new()

	return_player.name = player_name
	return_player.age = age
	return_player.score = 0
	return_player.id = -1

	player_was_added.emit(return_player)


	
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