class_name PlayerScoreEntry extends Control

signal set_player_score(score: int)
signal player_changed(name: String)
signal player_did_win(color: ColorResource)
signal winner_selected()
signal add_new_score()

@export var player_win_color: ColorResource
@export var first_animation_time: float = 0.3
## The time required to show the winning cards
@export var animation_start_time: float = 1

## The time required for the last winning card to show
@export var animation_end_time: float = 0.1

var _player_data: PlayerResource
var _did_win: bool = false

func _ready() -> void:
	if _player_data != null:
		_trigger_timed_score(_player_data.score)
		
		if _did_win:
			player_did_win.emit(player_win_color)

func set_player(player: PlayerResource, did_win: bool) -> void:
	_player_data = player
	player_changed.emit(player.get_display_name())
	set_player_score.emit(player.score)
	_did_win = did_win

func _trigger_timed_score(score: int) -> void:
	if score == 0:
		return
	await get_tree().create_timer(first_animation_time).timeout
	add_new_score.emit()
	score -= 1
	
	for i: int in score:
		var lerp_value: float = float(i) / float(score)
		var time: float = lerpf(animation_start_time, animation_end_time, lerp_value)
		await get_tree().create_timer(time).timeout
		
		add_new_score.emit()
	winner_is_selected()

func winner_is_selected() -> void:
	if _did_win:
		winner_selected.emit()
