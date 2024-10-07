extends TextureRect

@export var selection_material: Material

var initial_material: Material

func _ready():
	if material == null:
		initial_material = null
		return
	initial_material = material.duplicate()

func reset():
	material = initial_material

func activate():
	material = selection_material.duplicate()
