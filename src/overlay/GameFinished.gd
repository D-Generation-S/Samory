class_name GameFinished extends PopupWindow

signal finish_game_ui_loaded(players: Array[PlayerResource], winner: Array[PlayerResource])

var manager: PlayerManager
var played_deck: MemoryDeckResource

# Called when the node enters the scene tree for the first time.
func _ready():
	var players = manager.get_players()
	var highest_score = -1
	for player in players:
		if player.score >= highest_score:
			highest_score = player.score

	var winners: Array[PlayerResource] = []
	for player in players:
		if player.score == highest_score:
			winners.append(player)

	finish_game_ui_loaded.emit(players, winners)


func set_player_manager(player_manager: PlayerManager):
	manager = player_manager

func set_played_deck(deck: MemoryDeckResource):
	played_deck = deck