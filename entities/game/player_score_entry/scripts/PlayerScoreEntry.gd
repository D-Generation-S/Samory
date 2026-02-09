class_name PlayerScoreEntry extends Control

signal set_player_score(score: int)
signal player_changed(name: String)
signal player_did_win(color: ColorResource)
signal winner_selected()

@export var player_win_color: ColorResource

func set_player(player: PlayerResource, did_win: bool) -> void:
	player_changed.emit(player.get_display_name())
	set_player_score.emit(player.score)
	if did_win:
		player_did_win.emit(player_win_color)

func winner_is_selected() -> void:
	winner_selected.emit()
