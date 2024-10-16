extends ClickableButton

@export var player_target_node: VBoxContainer
@export var player_card_template: PackedScene

signal player_was_deleted()

var name_generator: NameGenerator

func _ready():
	name_generator = NameGenerator.new()

func _pressed():
	super()
	var player_name = name_generator.get_random_name()
	var age = randi() % 100 + 1

	var player = PlayerResource.new()
	player.name = player_name
	player.age = age

	var player_card = player_card_template.instantiate() as PlayerCard
	player_card.player_card = player
	player_card.getting_deleted.connect(func (): 
		player_was_deleted.emit()
	)
	player_target_node.add_child(player_card)
