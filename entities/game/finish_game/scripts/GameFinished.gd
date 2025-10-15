class_name GameFinished extends PopupWindow

signal finish_game_ui_loaded(players: Array[PlayerResource], winner: Array[PlayerResource])

var manager: PlayerManager
var played_deck: MemoryDeckResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var players: Array[PlayerResource] = []
	if manager != null:
		players = manager.get_players()
		
	var highest_score: int = -1
	for player: PlayerResource in players:
		if player.score >= highest_score:
			highest_score = player.score

	var winners: Array[PlayerResource] = []
	for player: PlayerResource in players:
		if player.score == highest_score:
			winners.append(player)

	finish_game_ui_loaded.emit(players, winners)


func set_player_manager(player_manager: PlayerManager) -> void:
	manager = player_manager

func set_played_deck(deck: MemoryDeckResource) -> void:
	played_deck = deck