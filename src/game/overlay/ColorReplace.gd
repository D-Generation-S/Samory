extends TextureRect

@export var default_color: ColorResource
@export var highlight_color: ColorResource

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if material is ShaderMaterial:
		material = material.duplicate_deep()
		active = true
		set_color(default_color.get_color())
		return

func set_default_color():
	if !active:
		return
	set_color(default_color.get_color())

func set_hightlight_color():
	if !active:
		return
	set_color(highlight_color.get_color())

func set_color(color: Color):
	var color_vector: Vector3 = Vector3(color.r, color.g, color.b)
	material.set_shader_parameter("replace_color", color_vector)
