extends TextureRect

class_name DeckPreviewSelection

@export var target_size: Vector2
@export var selection_material: Material
@export var deck_preview: DeckPreview
@export var focus_color: Color
@export var selected_color: Color

var initial_material: Material

func _ready():
	if material == null:
		initial_material = null
		return
	initial_material = material.duplicate_deep()

func set_image(new_texture: Texture2D):
	texture = new_texture
	scale = Vector2(target_size.x / new_texture.get_width(), target_size.y / new_texture.get_height())

func reset():
	if deck_preview.is_deck_selected():
		return
	material = initial_material

func activate():
	var color = focus_color
	if deck_preview.is_selected:
		color = selected_color

	material = selection_material.duplicate_deep()
	material.set("shader_parameter/effect_color", color)
