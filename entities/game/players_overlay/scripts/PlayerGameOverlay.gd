class_name PlayerGameOverlay extends Control

signal set_card_texture(texture: Texture2D)

@export var player_template: PackedScene
@export var player_target_control: Control

var _ui_information_system: UiInformationSystem = null
var _current_player: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	for child: Node in player_target_control.get_children():
		player_target_control.remove_child(child)
	var scene_parent: MemoryGame = get_tree().get_first_node_in_group("game_scene")
	var systems: Systems = scene_parent.get_systems()
	for system: Node in systems.get_systems():
		if system is UiInformationSystem:
			_ui_information_system = system
			break
	_ui_information_system.register_ui_element(name, self)

func set_texture(deck: MemoryDeckResource) -> void:
	set_card_texture.emit(deck.get_back_image())

func add_player(player: PlayerResource) -> void:
	var node: PlayerGameLabel = player_template.instantiate() as PlayerGameLabel
	if node == null:
		return
	node.set_player(player)
	player_target_control.add_child(node)
	set_card_texture.connect(node.set_texture)

func player_changed(player_id: int) -> void:
	_current_player = player_id
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

func game_state_changed(game_state: GameEnum.State) -> void:
	if game_state == GameEnum.State.TURN_END:
		round_end()
	if game_state == GameEnum.State.ANIMATION_CLEARED:
		visible = false

func get_global_position_of_current_player() -> Vector2:
	var target: Control = null
	for child: Control in player_target_control.get_children():
		if child.contained_player.id == _current_player:
			target = child
			break
	if target == null:
		target = self
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return global_position
	
	var ui_screen_pos: Vector2 = target.get_global_rect().get_center()
	ui_screen_pos.x = get_global_rect().end.x
	var viewport_center: Vector2 = get_viewport().get_visible_rect().get_center()
	
	var world_position: Vector2 = camera.global_position + (ui_screen_pos - viewport_center) / camera.zoom
	
	return world_position
