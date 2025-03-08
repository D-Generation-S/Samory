extends VBoxContainer

@export var player_template: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func build_player_statistic(players: Array[PlayerResource], winners: Array[PlayerResource]):
	players.sort_custom(sort_by_score)
	for player in players:
		var player_node = player_template.instantiate() as PlayerScoreEntry
		var did_win = false
		for winner in winners:
			if player.id == winner.id:
				did_win = true
				break
		player_node.set_player(player, did_win)
		add_child(player_node)
			
	
func sort_by_score(a: PlayerResource, b: PlayerResource):
	return a.score > b.score
