extends Node

@export var animation_scene: PackedScene

func _create_animation_scene_instance() -> AnimationScene:
	var scene = animation_scene.instantiate() as AnimationScene
	scene.animation_done.connect(_animation_done)
	get_tree().root.add_child(scene)
	get_tree().root.move_child(scene, 0)

	return scene

func _animation_done(scene: Node):
	scene.queue_free()

func transit_screen(new_scene: PackedScene) -> AnimationScene:
	var scene = _create_animation_scene_instance()
	scene.change_screen_to(new_scene)
	return scene

func transit_screen_by_node(new_scene: Node) -> AnimationScene:
	var scene = _create_animation_scene_instance()
	scene.change_screen_to_node(new_scene)
	return scene