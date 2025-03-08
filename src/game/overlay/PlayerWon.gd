extends HBoxContainer

@export var player_name_node: RichTextLabel

func _ready():
	player_name_node.bbcode_enabled = true

func set_winning_players(_players: Array[PlayerResource], winners: Array[PlayerResource]):
	winners.sort_custom(custom_sort)
	var text = "[right]"
	for player in winners:
		text = text + player.name + ", "
	player_name_node.text = text.left(-2) + "[/right]"

func custom_sort(a: PlayerResource, b: PlayerResource):
	return a.name < b.name