extends Control

class_name PlayerScoreEntry

@export var player_name: Label
@export var player_score: RichTextLabel
@export var player_win_icon: TextureRect
@export var player_win_color: ColorResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_score.bbcode_enabled = true

func set_player(player: PlayerResource, did_win: bool) -> void:
	player_win_icon.visible = did_win
	player_name.text = player.get_display_name()
	player_score.text = "[right]" + str(player.score) + "[/right]"
	if did_win:
		player_name.set("theme_override_colors/font_color",player_win_color.get_color())
		player_name.text = player_name.text
		player_score.text = "[right]" + player_win_color.get_color_bb_code() + str(player.score) + "[/color][/right]"
