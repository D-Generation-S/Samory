class_name AnimationScene extends Node2D

signal animation_done(scene: Node)
signal scene_instantiated(scene: Node)
signal transition_state(value: float)

@export var transition_time: float = 1
@export var active_scene_group: String = "active_scene"

var target_scene: Node
var tween: Tween

func change_screen_to(scene: PackedScene):
	if scene == null:
		return
	var loaded_scene = scene.instantiate()
	change_screen_to_node(loaded_scene)

func change_screen_to_node(node: Node):
	node.add_to_group(active_scene_group)
	target_scene = node
	tween = create_tween()
	tween.step_finished.connect(_transit_now)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_transition_animation, 0.0, 1.0, transition_time / 2)
	tween.tween_method(_transition_animation, 1.0, 0.0, transition_time / 2)
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