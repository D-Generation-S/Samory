extends Node

@export var animation_scene: PackedScene
@export var low_performance_scene: PackedScene

func _get_transition_scene() -> PackedScene:
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return low_performance_scene
	return animation_scene

func _create_animation_scene_instance() -> AnimationScene:
	var scene = _get_transition_scene().instantiate() as AnimationScene
	scene.animation_done.connect(_animation_done)
	get_tree().root.add_child(scene)
	get_tree().root.move_child(scene, 0)

	return scene

func _animation_done(scene: Node):
	scene.queue_free()



func transit_screen_with_position(new_scene: PackedScene, position: Vector2) -> AnimationScene:
	await RenderingServer.frame_post_draw
	var old_texture: Texture = ImageTexture.create_from_image( get_viewport().get_texture().get_image() )
	var scene = _create_animation_scene_instance()
	scene.change_screen_to(new_scene, old_texture, position)
	return scene

func transit_screen(new_scene: PackedScene) -> AnimationScene:
	return await transit_screen_with_position(new_scene, Vector2.ZERO)

func transit_screen_by_node_with_position(new_scene: Node, position: Vector2) -> AnimationScene:
	await RenderingServer.frame_post_draw
	var old_texture: Texture = ImageTexture.create_from_image( get_viewport().get_texture().get_image() )
	var scene = _create_animation_scene_instance()
	scene.change_screen_to_node(new_scene, old_texture, position)
	return scene

func transit_screen_by_node(new_scene: Node) -> AnimationScene:
	return await transit_screen_by_node_with_position(new_scene, Vector2.ZERO)