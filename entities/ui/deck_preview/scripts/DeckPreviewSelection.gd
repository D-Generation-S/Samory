extends TextureRect

class_name DeckPreviewSelection

@export var target_size: Vector2
@export var selection_material: Material
@export var deck_preview: DeckPreview
@export var color_on_focus: ColorResource
@export var color_on_select: ColorResource

var initial_material: Material

func _ready() -> void:
	if material == null:
		initial_material = null
		return
	initial_material = material.duplicate_deep()

func set_image(new_texture: Texture2D) -> void:
	texture = new_texture
	scale = Vector2(target_size.x / new_texture.get_width(), target_size.y / new_texture.get_height())

func reset() -> void:
	if deck_preview.is_deck_selected():
		return
	material = initial_material

func activate() -> void:
	var color: Color = color_on_focus.color
	if deck_preview._is_selected:
		color = color_on_select.color

	material = selection_material.duplicate_deep()
	material.set("shader_parameter/effect_color", color)
