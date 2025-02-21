extends ClickableButton

signal player_added(new_player: PlayerResource)

var name_generator: NameGenerator

func _ready():
	name_generator = NameGenerator.new()

func _pressed():
	super()
	var player_name = name_generator.get_random_name()

	var player = PlayerResource.new()
	player.name = player_name

	player_added.emit(player)
