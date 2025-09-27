extends TextureRect

@export var animation_duration: float = 0.4
@export var default_color: ColorResource
@export var highlight_color: ColorResource

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if material is ShaderMaterial:
		material = material.duplicate_deep()
		active = true
		_set_shader_target_color(default_color.get_color())
		return

func set_default_color():
	if !active:
		return
	set_color(default_color.get_color())

func set_highlight_color():
	if !active:
		return
	set_color(highlight_color.get_color())

func set_color(color: Color):
	var color_vector: Color = Color(color.r, color.g, color.b, 1)
	var tween = create_tween()
	var current_color: Color = Color(material.get_shader_parameter("target_color"))
	tween.tween_method(_set_shader_target_color, current_color, color_vector, animation_duration)

func _set_shader_target_color(color: Color):
	material.set_shader_parameter("target_color", color)
