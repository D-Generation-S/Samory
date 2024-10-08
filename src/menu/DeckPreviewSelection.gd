extends TextureRect

class_name DeckPreviewSelection

@export var target_size: Vector2
@export var selection_material: Material

var initial_material: Material

func _ready():
	if material == null:
		initial_material = null
		return
	initial_material = material.duplicate()

func set_image(new_texture: Texture2D):
	texture = new_texture
	scale = Vector2(target_size.x / new_texture.get_width(), target_size.y / new_texture.get_height())
	print(scale)

func reset():
	material = initial_material

func activate():
	material = selection_material.duplicate()
