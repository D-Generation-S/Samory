extends ClickableButton

signal player_added(new_player: PlayerResource)

var name_generator: NameGenerator

func _ready() -> void:
	super()
	name_generator = NameGenerator.new()

func _pressed() -> void:
	var player_name: String = name_generator.get_random_name()

	var player: PlayerResource = PlayerResource.new()
	player.name = player_name

	player_added.emit(player)
