extends VBoxContainer

@export var winning_sound: AudioStream
@export var player_template: PackedScene

var _win_sound_played: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func build_player_statistic(players: Array[PlayerResource], winners: Array[PlayerResource]) -> void:
	players.sort_custom(sort_by_score)
	for player: PlayerResource in players:
		var player_node: PlayerScoreEntry = player_template.instantiate() as PlayerScoreEntry
		player_node.winner_selected.connect(winning_player_selected)
		var did_win: bool = false
		for winner: PlayerResource in winners:
			if player.id == winner.id:
				did_win = true
				break
		player_node.set_player(player, did_win)
		add_child(player_node)
			
	
func sort_by_score(a: PlayerResource, b: PlayerResource) -> bool:
	return a.score > b.score

func winning_player_selected() -> void:
	if _win_sound_played or winning_sound == null:
		return
	_win_sound_played = true
	GlobalSoundManager.play_sound_effect(winning_sound)

