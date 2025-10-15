extends Control

@export var player_template: PackedScene
@export var player_target_control: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	for child: Node in player_target_control.get_children():
		player_target_control.remove_child(child)

func add_player(player: PlayerResource) -> void:
	var node: PlayerGameLabel = player_template.instantiate() as PlayerGameLabel
	if node == null:
		return
	node.set_player(player)
	player_target_control.add_child(node)

func player_changed(player_id: int) -> void:
	for child: Node in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.player_turn(player_id)

func player_scored(player_id: int, player_score: int) -> void:
	for child: Node in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.player_scored(player_id, player_score)

func round_end() -> void:
	for child: Node in player_target_control.get_children():
		if child is PlayerGameLabel:
			child.round_end()
	
func game_ended() -> void:
	visible = false

func game_state_changed(game_state:int) -> void:
	if game_state == GameState.ROUND_END:
		round_end()
