extends Control

@export var player_template: PackedScene
@export var player_target_control: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in player_target_control.get_children():
		player_target_control.remove_child(child)

func add_player(player: PlayerResource):
	var node = player_template.instantiate()
	if node is PlayerGameLabel:
		node.set_player(player)
	player_target_control.add_child(node)

func player_changed(player_id: int):
	for child in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.player_turn(player_id)

func player_scored(player_id: int, player_score: int):
	for child in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.player_scored(player_id, player_score)

func round_end():
	for child in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.round_end()
	
func game_ended():
	visible = false
