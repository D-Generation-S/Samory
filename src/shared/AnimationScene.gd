class_name AnimationScene extends Node2D

signal animation_done(scene: Node)
signal scene_instantiated(scene: Node)
signal transition_state(value: float)
signal texture_changed(new_texture: Texture)
signal start_position_changed(new_position: Vector2)

@export var transition_time_in: float = 0.5
@export var transition_time_out: float = 0.5
@export var active_scene_group: String = "active_scene"

var target_scene: Node
var tween: Tween

func _ready():
	if z_index == 0:
		z_index = 1000
	for child in get_children():
		if child is CanvasLayer:
			child.layer = 128

func change_screen_to(scene: PackedScene, old_texture: Texture, transition_start_position: Vector2):
	if scene == null:
		return
	var loaded_scene = scene.instantiate()
	change_screen_to_node(loaded_scene, old_texture, transition_start_position)

func change_screen_to_node(node: Node, old_texture: Texture, transition_start_position: Vector2):
	texture_changed.emit(old_texture)
	start_position_changed.emit(transition_start_position)
	node.add_to_group(active_scene_group)
	target_scene = node
	tween = create_tween()
	tween.step_finished.connect(_transit_now)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_transition_animation, 0.0, 1.0, transition_time_in )
	tween.tween_method(_transition_animation, 1.0, 0.0, transition_time_out)
	tween.finished.connect(_animation_completed)
	
func _transition_animation(value: float):
	transition_state.emit(value)

func _transit_now(_step_id: int):
	if target_scene != null:
		for scene in get_tree().get_nodes_in_group(active_scene_group):
			scene.queue_free()

		GlobalGameManagerAccess.get_game_manager().add_child(target_scene)
		scene_instantiated.emit(target_scene)
		target_scene = null
	

func _animation_completed():
	animation_done.emit(self)