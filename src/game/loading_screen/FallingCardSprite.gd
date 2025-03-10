extends Sprite2D

@export var collision_shape: CollisionShape2D
@export var max_width: int = 150
@export var max_height: int = 150

var tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if collision_shape == null:
		printerr("Missing collision shape")
		queue_free()
		return
	if material:
		material = material.duplicate()
	var texture_image = texture.get_image()
	texture_image.resize(max_width, max_height)
	texture = ImageTexture.create_from_image(texture_image)
	if collision_shape != null:
		var real_collision_shape = collision_shape.shape as RectangleShape2D
		if real_collision_shape == null:
			return
		real_collision_shape.size = texture.get_size()

func reset():
	if tween and tween.is_running():
		tween.kill()
	tween = null
	update_radius(0)
	collision_shape.disabled = false

func dissolve(mouse_position: Vector2):
	if tween != null:
		return
	collision_shape.disabled = true
	if get_rect().has_point(mouse_position):
		var uv = get_local_uv(mouse_position)
		burn_card(uv)

func get_local_uv(local_click_pos: Vector2) -> Vector2:
	var texture_size = texture.get_size()
	var top_left_pos = local_click_pos + (texture_size) / 2
	var uv = top_left_pos / (texture_size)
	return uv

func burn_card(uv: Vector2):
	if material and material is ShaderMaterial:
		tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		material.set_shader_parameter("position", uv)
		tween.tween_method(update_radius, 0.0, 2.0, 1.5)

func update_radius(value: float):
	if material and material is ShaderMaterial:
		material.set_shader_parameter("radius", value)