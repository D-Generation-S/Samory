extends Node

class_name PlayerManager

signal player_changed(player_id: int)
signal player_resource_changed(current_player: PlayerResource)
signal player_added(player: PlayerResource)
signal player_score_changed(player_id: int, score: int)

var players: Array[PlayerResource]
var current_player_index: int

var _initial_announce: bool = false

func add_players(players_to_add: Array[PlayerResource]) -> void:
	players_to_add.sort_custom(player_sort)
	players = players_to_add
	current_player_index = -1
	for player: PlayerResource in players:
		player_added.emit(player)
	next_player()

func player_sort(a: PlayerResource, b: PlayerResource) -> bool:
	return a.order_number < b.order_number

func get_current_player() -> PlayerResource:
	return players[current_player_index]

func get_players() -> Array[PlayerResource]:
	return players

func next_player() -> void:
	current_player_index = current_player_index + 1
	if current_player_index > players.size() -1:
		current_player_index = 0
	player_changed.emit(get_current_player().id)
	player_resource_changed.emit(get_current_player())

func player_scored(scoring_player: PlayerResource) -> void:
	var selected_player: PlayerResource = null
	for player: PlayerResource in players:
		if player.id == scoring_player.id:
			selected_player = player
			break
	set_player_score(selected_player.id, selected_player.score + 1)

func game_state_changed(game_state:int) -> void:
	if game_state == GameState.ROUND_START and !_initial_announce:
		_initial_announce = true
		player_resource_changed.emit(get_current_player())
	if game_state == GameState.ROUND_END:
		next_player()

func set_player_by_id(id: int) -> void:
	var index: int = players.find_custom(func(player: PlayerResource) -> bool: return player.id == id)
	if index == -1:
		return

	current_player_index = index
	player_changed.emit(get_current_player().id)
	player_resource_changed.emit(get_current_player())

func set_player_score(id: int, score: int) -> void:
	var index: int = players.find_custom(func(player: PlayerResource) -> bool: return player.id == id)
	if index == -1:
		return
	players[index].score = score
	player_score_changed.emit(players[index].id, players[index].score)