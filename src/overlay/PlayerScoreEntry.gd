extends Control

class_name PlayerScoreEntry

@export var player_name: RichTextLabel
@export var player_score: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name.bbcode_enabled = true
	player_score.bbcode_enabled = true

func set_player(player: PlayerResource, did_win: bool):
	player_name.text = player.name
	player_score.text = "[right]" + str(player.score) + "[/right]"
	if did_win:
		player_name.text = "[color=red]" + player_name.text + "[/color]"
		player_score.text = "[right][color=red]" + str(player.score) + "[/color][/right]"