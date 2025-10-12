extends HBoxContainer

@export var player_name_node: RichTextLabel

func _ready() -> void:
	player_name_node.bbcode_enabled = true

func set_winning_players(_players: Array[PlayerResource], winners: Array[PlayerResource]) -> void:
	winners.sort_custom(custom_sort)
	var text: String = "[right]"
	for player: PlayerResource in winners:
		text = text + player.name + ", "
	player_name_node.text = text.left(-2) + "[/right]"

func custom_sort(a: PlayerResource, b: PlayerResource) -> bool:
	return a.name < b.name