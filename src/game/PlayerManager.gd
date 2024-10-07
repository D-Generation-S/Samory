extends Node

class_name PlayerManager

signal player_changed(player_id: int)
signal player_added(player: PlayerResource)
signal player_score_changed(player_id: int, score: int)

var players: Array[PlayerResource]
var current_player_index: int

func add_players(players_to_add: Array[PlayerResource]):
	print("Player manager add players")
	players_to_add.sort_custom(player_sort)
	players = players_to_add
	current_player_index = -1
	for player in players:
		player_added.emit(player)
	next_player()

func player_sort(a, b):
	if typeof(a) != typeof(b):
		return false
	return a.age < b.age

func get_current_player() -> PlayerResource:
	return players[current_player_index]

func get_players() -> Array[PlayerResource]:
	return players

func next_player():
	current_player_index = current_player_index + 1
	if current_player_index > players.size() -1:
		current_player_index = 0
	player_changed.emit(get_current_player().id)

func player_scored(player_id):
	var selected_player = null
	for player in players:
		if player.id == player_id:
			selected_player = player
			break
	selected_player.score = selected_player.score + 1
	player_score_changed.emit(selected_player.id, selected_player.score)